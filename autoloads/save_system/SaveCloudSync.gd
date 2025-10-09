class_name SaveCloudSync
extends RefCounted

# =============================================================================
# SAVE CLOUD SYNCHRONIZATION
# =============================================================================
# Handles cloud synchronization with Supabase
# - Upload/download save data
# - Conflict resolution (Cloud-Primary strategy)
# - Async sync queue management
# =============================================================================

signal cloud_sync_started()
signal cloud_sync_completed(success: bool)
signal conflict_detected(local_data: Dictionary, cloud_data: Dictionary)

const CLOUD_SYNC_ENABLED = true
const CLOUD_PRIMARY = true  # Cloud always wins in conflicts

var node: Node  # Reference to parent node for HTTPRequest
var security: SaveSecurity
var is_syncing: bool = false
var last_cloud_sync: int = 0
var pending_sync_queue: Array[Dictionary] = []

func _init(parent_node: Node, save_security: SaveSecurity):
	node = parent_node
	security = save_security

func save_to_cloud(save_data: Dictionary) -> bool:
	"""Upload save data to Supabase Cloud"""
	if not CLOUD_SYNC_ENABLED:
		print("Cloud sync disabled")
		return false

	if not SupabaseClient.is_authenticated():
		print("User not authenticated, cannot save to cloud")
		return false

	if is_syncing:
		print("Already syncing, queueing save operation")
		pending_sync_queue.append(save_data.duplicate())
		return false

	is_syncing = true
	cloud_sync_started.emit()

	print("💾 Uploading save to cloud...")

	# Calculate HMAC checksum for integrity
	var checksum = security.calculate_save_checksum(save_data)

	# Prepare cloud save data
	var cloud_save_data = save_data.duplicate()
	cloud_save_data["checksum"] = checksum
	cloud_save_data["synced_at"] = Time.get_unix_time_from_system()

	# Upload to Supabase
	await upload_to_supabase(cloud_save_data)

	is_syncing = false
	last_cloud_sync = Time.get_unix_time_from_system()

	# Process queued saves
	if pending_sync_queue.size() > 0:
		var next_save = pending_sync_queue.pop_front()
		await save_to_cloud(next_save)

	return true

func upload_to_supabase(data: Dictionary) -> bool:
	"""Upload save data to Supabase via HTTP request"""
	var user_id = SupabaseClient.get_current_user_id()
	if user_id == "":
		push_error("Cannot upload: No user ID")
		cloud_sync_completed.emit(false)
		return false

	var url = SupabaseClient.SUPABASE_URL + "/rest/v1/save_data"
	var headers = [
		"Content-Type: application/json",
		"apikey: " + SupabaseClient.SUPABASE_ANON_KEY,
		"Authorization: Bearer " + _get_access_token(),
		"Prefer: resolution=merge-duplicates"
	]

	var body = JSON.stringify({
		"user_id": user_id,
		"data": data,
		"version": 1
	})

	var http = HTTPRequest.new()
	node.add_child(http)
	http.request_completed.connect(_on_upload_completed)

	var error = http.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("Upload request failed: %d" % error)
		http.queue_free()
		cloud_sync_completed.emit(false)
		return false

	return true

func _on_upload_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	"""Handle upload completion"""
	var http = node.get_node_or_null("HTTPRequest")
	if http:
		http.queue_free()

	if response_code == 200 or response_code == 201:
		print("✅ Save uploaded to cloud successfully!")
		cloud_sync_completed.emit(true)
	else:
		var response_text = body.get_string_from_utf8()
		push_error("Upload failed: %d - %s" % [response_code, response_text])
		cloud_sync_completed.emit(false)

func load_from_cloud() -> Dictionary:
	"""Download save data from Supabase Cloud"""
	if not CLOUD_SYNC_ENABLED:
		print("Cloud sync disabled")
		return {}

	if not SupabaseClient.is_authenticated():
		print("User not authenticated, cannot load from cloud")
		return {}

	print("☁️ Downloading save from cloud...")

	var cloud_data = await download_from_supabase()

	if cloud_data.is_empty():
		print("No cloud save found")
		return {}

	# Verify checksum
	if not security.verify_save_checksum(cloud_data):
		push_error("Cloud save checksum verification failed! Data may be corrupted.")
		return {}

	print("✅ Cloud save loaded")
	return cloud_data

func download_from_supabase() -> Dictionary:
	"""Download save data from Supabase"""
	var user_id = SupabaseClient.get_current_user_id()
	if user_id == "":
		push_error("Cannot download: No user ID")
		return {}

	var url = SupabaseClient.SUPABASE_URL + "/rest/v1/save_data?user_id=eq." + user_id + "&select=*"
	var headers = [
		"Content-Type: application/json",
		"apikey: " + SupabaseClient.SUPABASE_ANON_KEY,
		"Authorization: Bearer " + _get_access_token()
	]

	var http = HTTPRequest.new()
	node.add_child(http)

	var error = http.request(url, headers, HTTPClient.METHOD_GET)
	if error != OK:
		push_error("Download request failed: %d" % error)
		http.queue_free()
		return {}

	var response = await http.request_completed
	http.queue_free()

	var result = response[0]
	var response_code = response[1]
	var body = response[3]

	if response_code != 200:
		push_error("Download failed: %d" % response_code)
		return {}

	var response_text = body.get_string_from_utf8()
	var json = JSON.new()
	var parse_result = json.parse(response_text)

	if parse_result != OK:
		push_error("Failed to parse cloud save response")
		return {}

	var data_array = json.data
	if data_array is Array and data_array.size() > 0:
		var save_record = data_array[0]
		return save_record.get("data", {})

	return {}

func sync_save(local_data: Dictionary) -> Dictionary:
	"""
	Intelligent sync: Compare local and cloud, apply Cloud-First strategy
	Returns the authoritative data to use
	"""
	if not CLOUD_SYNC_ENABLED or not SupabaseClient.is_authenticated():
		return local_data

	print("🔄 Syncing save data...")

	# Get cloud data
	var cloud_data = await download_from_supabase()

	# No cloud data? Upload local
	if cloud_data.is_empty():
		print("No cloud save, uploading local...")
		await save_to_cloud(local_data)
		return local_data

	# No local data? Use cloud
	if local_data.is_empty():
		print("No local save, using cloud...")
		return cloud_data

	# Both exist: Compare timestamps
	var local_timestamp = local_data.get("timestamp", 0)
	var cloud_timestamp = cloud_data.get("timestamp", 0)

	print("Local timestamp: %d, Cloud timestamp: %d" % [local_timestamp, cloud_timestamp])

	# Cloud-Primary Strategy: Cloud always wins
	if CLOUD_PRIMARY:
		print("🌩️ Cloud-Primary: Using cloud save")
		return cloud_data

	# Fallback: Newest wins
	if cloud_timestamp > local_timestamp:
		print("☁️ Cloud save is newer")
		return cloud_data
	else:
		print("💾 Local save is newer, uploading...")
		await save_to_cloud(local_data)
		return local_data

func auto_sync_on_event(event_name: String, save_data: Dictionary):
	"""Automatically sync to cloud on important game events"""
	print("🎮 Game event: %s - Auto-syncing..." % event_name)

	if CLOUD_SYNC_ENABLED and SupabaseClient.is_authenticated():
		await save_to_cloud(save_data)

func _get_access_token() -> String:
	"""Get access token from SupabaseClient"""
	if not OS.has_feature("web"):
		return ""

	var token = JavaScriptBridge.eval("sessionStorage.getItem('bktd_auth_token')", true)
	if token == "null" or token == "":
		return ""
	return token
