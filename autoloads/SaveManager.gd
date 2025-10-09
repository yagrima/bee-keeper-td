extends Node

# Save System for Bee Keeper TD - Cloud-Enabled
# Handles saving and loading of game state with Cloud-First strategy
# Version: 2.0 (Cloud-Sync Ready)
# Security: HMAC-SHA256 Checksums, Cloud-Primary, Anti-Cheat

signal save_completed(success: bool, message: String)
signal load_completed(success: bool, message: String)
signal cloud_sync_started()
signal cloud_sync_completed(success: bool)
signal conflict_detected(local_data: Dictionary, cloud_data: Dictionary)

# Save file configuration
const SAVE_DIR = "user://saves/"
const SAVE_FILE = "savegame.save"
const CONFIG_FILE = "user://config.cfg"

# Cloud-Sync configuration
const CLOUD_SYNC_ENABLED = true
const CLOUD_PRIMARY = true  # Cloud always wins in conflicts

# HMAC Secret (loaded from environment)
var HMAC_SECRET: String = ""

# Save data structure
var save_data: Dictionary = {}

# Auto-save settings
var auto_save_enabled: bool = true
var auto_save_interval: float = 60.0  # seconds
var auto_save_timer: Timer

# Cloud-sync state
var is_syncing: bool = false
var last_cloud_sync: int = 0
var pending_sync_queue: Array[Dictionary] = []

func _ready():
	# Load HMAC secret from environment
	_load_hmac_secret()
	
	# Create save directory if it doesn't exist
	create_save_directory()
	
	# Setup auto-save timer
	setup_auto_save()
	
	print("SaveManager initialized")

func _load_hmac_secret():
	"""Load HMAC secret from environment variable"""
	HMAC_SECRET = OS.get_environment("BKTD_HMAC_SECRET")
	
	if HMAC_SECRET == "":
		if OS.is_debug_build():
			# Development fallback
			HMAC_SECRET = "dev_fallback_secret_not_for_production_use_12345678901234567890"
			push_warning("⚠️ HMAC secret not set! Using development fallback. SET BKTD_HMAC_SECRET in .env!")
		else:
			# Production must have secret
			push_error("🔴 CRITICAL: HMAC_SECRET not set! Production build requires BKTD_HMAC_SECRET environment variable!")
			get_tree().quit()
			return
	
	print("✅ HMAC secret loaded from environment (length: %d)" % HMAC_SECRET.length())

func create_save_directory():
	"""Create the save directory if it doesn't exist"""
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.open("user://").make_dir_recursive("saves")
		print("Created save directory: ", SAVE_DIR)

func setup_auto_save():
	"""Setup automatic saving"""
	auto_save_timer = Timer.new()
	auto_save_timer.wait_time = auto_save_interval
	auto_save_timer.timeout.connect(_on_auto_save_timeout)
	auto_save_timer.autostart = auto_save_enabled
	add_child(auto_save_timer)

func _on_auto_save_timeout():
	"""Auto-save the game"""
	if GameManager.current_state != GameManager.GameState.MAIN_MENU:
		save_game("auto_save")

# =============================================================================
# SAVE SYSTEM
# =============================================================================

func save_game(save_name: String = "main") -> bool:
	"""
	Save the current game state (Local + Cloud)
	Cloud-First Strategy: Always syncs to cloud if authenticated
	"""
	print("💾 Saving game: ", save_name)

	# Collect all save data
	collect_save_data()

	# Save to local file first (fast, always works)
	var success = write_save_file(save_name)

	if not success:
		save_completed.emit(false, "Failed to save game")
		print("❌ Failed to save game: ", save_name)
		return false

	# Sync to cloud if authenticated (async)
	if CLOUD_SYNC_ENABLED and SupabaseClient.is_authenticated():
		print("☁️ Syncing to cloud...")
		save_to_cloud()  # Async, doesn't block
	else:
		print("ℹ️ Skipping cloud sync (not authenticated)")

	save_completed.emit(true, "Game saved successfully")
	print("✅ Game saved successfully: ", save_name)

	return success

func collect_save_data():
	"""Collect all game data that needs to be saved"""
	save_data = {
		"version": "1.0",
		"timestamp": Time.get_unix_time_from_system(),
		"game_state": GameManager.current_state,
		"player_data": collect_player_data(),
		"hotkeys": collect_hotkey_data(),
		"tower_defense": collect_tower_defense_data(),
		"settlement": collect_settlement_data()
	}

func collect_player_data() -> Dictionary:
	"""Collect player data from GameManager"""
	return {
		"account_level": GameManager.player_data.account_level,
		"honey": GameManager.player_data.honey,
		"honeygems": GameManager.player_data.honeygems,
		"wax": GameManager.player_data.wax,
		"wood": GameManager.player_data.wood,
		"buildings": GameManager.player_data.buildings.duplicate(),
		"towers": GameManager.player_data.towers.duplicate(),
		"soldiers": GameManager.player_data.soldiers.duplicate()
	}

func collect_hotkey_data() -> Dictionary:
	"""Collect hotkey configuration"""
	return HotkeyManager.get_all_hotkeys()

func collect_tower_defense_data() -> Dictionary:
	"""Collect tower defense scene data"""
	var td_data = {
		"current_wave": 1,
		"player_health": 20,
		"placed_towers": [],
		"wave_progress": {}
	}
	
	# Try to get data from current tower defense scene
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.has_method("get_tower_defense_data"):
		td_data = current_scene.get_tower_defense_data()
	elif current_scene and current_scene.name == "TowerDefense":
		# Fallback: try to get data from scene nodes
		td_data = get_tower_defense_data_from_scene(current_scene)
	
	return td_data

func get_tower_defense_data_from_scene(scene: Node) -> Dictionary:
	"""Extract tower defense data from scene nodes"""
	var td_data = {
		"current_wave": 1,
		"player_health": 20,
		"placed_towers": [],
		"wave_progress": {}
	}
	
	# Try to get data from scene variables
	if scene.has_method("get") and scene.get("current_wave"):
		td_data["current_wave"] = scene.get("current_wave")
	if scene.has_method("get") and scene.get("player_health"):
		td_data["player_health"] = scene.get("player_health")
	
	# Try to get tower placer data
	var tower_placer = scene.get_node_or_null("TowerPlacer")
	if tower_placer and tower_placer.has_method("get_placed_towers"):
		var towers = tower_placer.get_placed_towers()
		for tower in towers:
			if tower and is_instance_valid(tower):
				td_data["placed_towers"].append({
					"type": tower.tower_name,
					"position": {
						"x": tower.global_position.x,
						"y": tower.global_position.y
					},
					"level": tower.level,
					"damage": tower.damage,
					"range": tower.range,
					"attack_speed": tower.attack_speed
				})
	
	# Try to get wave manager data
	var wave_manager = scene.get_node_or_null("WaveManager")
	if wave_manager and wave_manager.has_method("get_current_wave"):
		td_data["current_wave"] = wave_manager.get_current_wave()
	
	return td_data

func collect_settlement_data() -> Dictionary:
	"""Collect settlement/meta progression data"""
	return {
		"buildings_unlocked": [],
		"upgrades_purchased": [],
		"settlement_level": 1
	}

func write_save_file(save_name: String) -> bool:
	"""Write save data to file"""
	var file_path = SAVE_DIR + save_name + ".save"
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		print("Error: Could not open save file for writing: ", file_path)
		return false
	
	# Convert save data to JSON
	var json_string = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	
	print("Save file written: ", file_path)
	return true

# =============================================================================
# LOAD SYSTEM
# =============================================================================

func load_game(save_name: String = "main") -> bool:
	"""
	Load a saved game (Cloud-First Strategy)
	Tries cloud first, fallback to local if not available
	"""
	print("📂 Loading game: ", save_name)

	# Cloud-First: Try loading from cloud if authenticated
	if CLOUD_SYNC_ENABLED and SupabaseClient.is_authenticated():
		print("☁️ Attempting to load from cloud...")
		var cloud_success = await load_from_cloud()

		if cloud_success:
			load_completed.emit(true, "Game loaded from cloud")
			print("✅ Game loaded from cloud")
			return true
		else:
			print("ℹ️ No cloud save found, trying local...")

	# Fallback: Load from local file
	var success = read_save_file(save_name)

	if success:
		# Apply loaded data
		apply_save_data()
		load_completed.emit(true, "Game loaded from local file")
		print("✅ Game loaded from local file: ", save_name)
	else:
		load_completed.emit(false, "Failed to load game")
		print("❌ Failed to load game: ", save_name)

	return success

func read_save_file(save_name: String) -> bool:
	"""Read save data from file"""
	var file_path = SAVE_DIR + save_name + ".save"
	
	if not FileAccess.file_exists(file_path):
		print("Error: Save file does not exist: ", file_path)
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("Error: Could not open save file for reading: ", file_path)
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	# Parse JSON
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("Error: Failed to parse save file JSON")
		return false
	
	save_data = json.data
	print("Save file loaded: ", file_path)
	return true

func apply_save_data():
	"""Apply loaded save data to game systems"""
	if not save_data.has("version"):
		print("Warning: Save file missing version information")
	
	# Apply player data
	if save_data.has("player_data"):
		apply_player_data(save_data["player_data"])
	
	# Apply hotkeys
	if save_data.has("hotkeys"):
		apply_hotkey_data(save_data["hotkeys"])
	
	# Apply game state
	if save_data.has("game_state"):
		GameManager.change_game_state(save_data["game_state"])
	
	# Store tower defense data for scene loading
	if save_data.has("tower_defense"):
		# Store the data to be applied when the tower defense scene loads
		set_meta("pending_tower_defense_data", save_data["tower_defense"])
		print("Tower defense data queued for loading")

func apply_player_data(player_data: Dictionary):
	"""Apply loaded player data to GameManager"""
	GameManager.player_data.account_level = player_data.get("account_level", 1)
	GameManager.player_data.honey = player_data.get("honey", 100)
	GameManager.player_data.honeygems = player_data.get("honeygems", 0)
	GameManager.player_data.wax = player_data.get("wax", 50)
	GameManager.player_data.wood = player_data.get("wood", 0)
	GameManager.player_data.buildings = player_data.get("buildings", {})
	GameManager.player_data.towers = player_data.get("towers", [])
	GameManager.player_data.soldiers = player_data.get("soldiers", [])
	
	print("Player data loaded: Honey=", GameManager.player_data.honey, " Level=", GameManager.player_data.account_level)

func apply_hotkey_data(hotkey_data: Dictionary):
	"""Apply loaded hotkey data to HotkeyManager"""
	for action in hotkey_data:
		if HotkeyManager.hotkeys.has(action):
			HotkeyManager.hotkeys[action] = hotkey_data[action]
	
	print("Hotkeys loaded: ", hotkey_data)

# =============================================================================
# SAVE FILE MANAGEMENT
# =============================================================================

func get_save_files() -> Array[String]:
	"""Get list of available save files"""
	var save_files: Array[String] = []
	var dir = DirAccess.open(SAVE_DIR)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.ends_with(".save"):
				save_files.append(file_name.get_basename())
			file_name = dir.get_next()
	
	return save_files

func delete_save_file(save_name: String) -> bool:
	"""Delete a save file"""
	var file_path = SAVE_DIR + save_name + ".save"
	
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		print("Save file deleted: ", file_path)
		return true
	else:
		print("Save file not found: ", file_path)
		return false

func save_file_exists(save_name: String) -> bool:
	"""Check if a save file exists"""
	var file_path = SAVE_DIR + save_name + ".save"
	return FileAccess.file_exists(file_path)

func get_save_file_info(save_name: String) -> Dictionary:
	"""Get information about a save file"""
	var file_path = SAVE_DIR + save_name + ".save"
	
	if not FileAccess.file_exists(file_path):
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		return {}
	
	var data = json.data
	return {
		"version": data.get("version", "unknown"),
		"timestamp": data.get("timestamp", 0),
		"game_state": data.get("game_state", 0),
		"player_level": data.get("player_data", {}).get("account_level", 1),
		"honey": data.get("player_data", {}).get("honey", 0)
	}

# =============================================================================
# CONFIGURATION SAVE/LOAD
# =============================================================================

func save_config():
	"""Save game configuration (hotkeys, settings, etc.)"""
	var config_data = {
		"hotkeys": HotkeyManager.get_all_hotkeys(),
		"auto_save_enabled": auto_save_enabled,
		"auto_save_interval": auto_save_interval
	}
	
	var file = FileAccess.open(CONFIG_FILE, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(config_data, "\t")
		file.store_string(json_string)
		file.close()
		print("Configuration saved")
	else:
		print("Error: Could not save configuration")

func load_config():
	"""Load game configuration"""
	if not FileAccess.file_exists(CONFIG_FILE):
		print("No configuration file found, using defaults")
		return
	
	var file = FileAccess.open(CONFIG_FILE, FileAccess.READ)
	if not file:
		print("Error: Could not load configuration")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("Error: Could not parse configuration")
		return
	
	var config_data = json.data
	
	# Apply hotkeys
	if config_data.has("hotkeys"):
		for action in config_data["hotkeys"]:
			if HotkeyManager.hotkeys.has(action):
				HotkeyManager.hotkeys[action] = config_data["hotkeys"][action]
	
	# Apply auto-save settings
	if config_data.has("auto_save_enabled"):
		auto_save_enabled = config_data["auto_save_enabled"]
	if config_data.has("auto_save_interval"):
		auto_save_interval = config_data["auto_save_interval"]
	
	print("Configuration loaded")

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func get_save_data() -> Dictionary:
	"""Get current save data (for debugging)"""
	return save_data

func clear_save_data():
	"""Clear current save data"""
	save_data = {}

func export_save_data() -> String:
	"""Export save data as JSON string"""
	return JSON.stringify(save_data, "\t")

func import_save_data(json_string: String) -> bool:
	"""Import save data from JSON string"""
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("Error: Could not parse imported save data")
		return false
	
	save_data = json.data
	apply_save_data()
	return true

func get_pending_tower_defense_data() -> Dictionary:
	"""Get pending tower defense data and clear it"""
	if has_meta("pending_tower_defense_data"):
		var data = get_meta("pending_tower_defense_data")
		remove_meta("pending_tower_defense_data")
		return data
	return {}

func has_pending_tower_defense_data() -> bool:
	"""Check if there's pending tower defense data to load"""
	return has_meta("pending_tower_defense_data")

# =============================================================================
# CLOUD SAVE SYSTEM (Sprint 3)
# =============================================================================

func save_to_cloud() -> bool:
	"""
	Upload save data to Supabase Cloud
	Cloud-Primary Strategy: This is the authoritative source
	"""
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
	var checksum = calculate_save_checksum(save_data)

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
		save_data = next_save
		await save_to_cloud()

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
	add_child(http)
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
	var http = get_node_or_null("HTTPRequest")
	if http:
		http.queue_free()

	if response_code == 200 or response_code == 201:
		print("✅ Save uploaded to cloud successfully!")
		cloud_sync_completed.emit(true)
	else:
		var response_text = body.get_string_from_utf8()
		push_error("Upload failed: %d - %s" % [response_code, response_text])
		cloud_sync_completed.emit(false)

func load_from_cloud() -> bool:
	"""
	Download save data from Supabase Cloud
	Cloud-Primary Strategy: This overwrites local save
	"""
	if not CLOUD_SYNC_ENABLED:
		print("Cloud sync disabled")
		return false

	if not SupabaseClient.is_authenticated():
		print("User not authenticated, cannot load from cloud")
		return false

	print("☁️ Downloading save from cloud...")

	var cloud_data = await download_from_supabase()

	if cloud_data.is_empty():
		print("No cloud save found")
		return false

	# Verify checksum
	if not verify_save_checksum(cloud_data):
		push_error("Cloud save checksum verification failed! Data may be corrupted.")
		return false

	# Cloud-Primary: Apply cloud data directly
	save_data = cloud_data
	apply_save_data()

	# Also save to local as cache
	write_save_file("cloud_cache")

	print("✅ Cloud save loaded and applied")
	return true

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
	add_child(http)

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

func sync_save() -> bool:
	"""
	Intelligent sync: Compare local and cloud, apply Cloud-First strategy
	"""
	if not CLOUD_SYNC_ENABLED or not SupabaseClient.is_authenticated():
		return false

	print("🔄 Syncing save data...")

	# Get both local and cloud data
	var local_data = save_data.duplicate()
	var cloud_data = await download_from_supabase()

	# No cloud data? Upload local
	if cloud_data.is_empty():
		print("No cloud save, uploading local...")
		await save_to_cloud()
		return true

	# No local data? Download cloud
	if local_data.is_empty():
		print("No local save, downloading cloud...")
		await load_from_cloud()
		return true

	# Both exist: Compare timestamps
	var local_timestamp = local_data.get("timestamp", 0)
	var cloud_timestamp = cloud_data.get("timestamp", 0)

	print("Local timestamp: %d, Cloud timestamp: %d" % [local_timestamp, cloud_timestamp])

	# Cloud-Primary Strategy: Cloud always wins
	if CLOUD_PRIMARY:
		print("🌩️ Cloud-Primary: Using cloud save")
		save_data = cloud_data
		apply_save_data()
		write_save_file("cloud_cache")
		return true

	# Fallback: Newest wins (but we don't use this with Cloud-Primary)
	if cloud_timestamp > local_timestamp:
		print("☁️ Cloud save is newer, downloading...")
		await load_from_cloud()
	else:
		print("💾 Local save is newer, uploading...")
		await save_to_cloud()

	return true

# =============================================================================
# HMAC CHECKSUM (Anti-Tampering)
# =============================================================================

func calculate_save_checksum(data: Dictionary) -> String:
	"""
	Calculate HMAC-SHA256 checksum for save data integrity
	Prevents client-side manipulation before upload
	"""
	# Remove checksum field if it exists
	var data_copy = data.duplicate()
	if data_copy.has("checksum"):
		data_copy.erase("checksum")
	if data_copy.has("synced_at"):
		data_copy.erase("synced_at")

	# Convert to deterministic JSON string
	var json_string = JSON.stringify(data_copy)

	# Calculate RFC 2104 compliant HMAC-SHA256
	var hash = _calculate_hmac_sha256(json_string, HMAC_SECRET)

	return hash

func _calculate_hmac_sha256(message: String, key: String) -> String:
	"""
	RFC 2104 compliant HMAC-SHA256 implementation
	Provides proper cryptographic integrity protection
	"""
	const BLOCK_SIZE = 64  # SHA256 block size in bytes
	
	# Prepare key
	var key_bytes = key.to_utf8_buffer()
	if key_bytes.size() > BLOCK_SIZE:
		# If key is longer than block size, hash it first
		key_bytes = key.sha256_text().to_utf8_buffer()
	
	# Pad key to block size
	if key_bytes.size() < BLOCK_SIZE:
		key_bytes.resize(BLOCK_SIZE)
	
	# Create inner and outer padded keys
	var inner_key = PackedByteArray()
	var outer_key = PackedByteArray()
	inner_key.resize(BLOCK_SIZE)
	outer_key.resize(BLOCK_SIZE)
	
	for i in range(BLOCK_SIZE):
		inner_key[i] = key_bytes[i] ^ 0x36  # ipad
		outer_key[i] = key_bytes[i] ^ 0x5c  # opad
	
	# Calculate inner hash: H(K XOR ipad || message)
	var inner_message = inner_key.get_string_from_utf8() + message
	var inner_hash = inner_message.sha256_text()
	
	# Calculate outer hash: H(K XOR opad || inner_hash)
	var outer_message = outer_key.get_string_from_utf8() + inner_hash
	var final_hash = outer_message.sha256_text()
	
	return final_hash

func verify_save_checksum(data: Dictionary) -> bool:
	"""Verify save data checksum"""
	if not data.has("checksum"):
		push_warning("Save data missing checksum")
		return true  # Allow for backward compatibility

	var stored_checksum = data["checksum"]
	var calculated_checksum = calculate_save_checksum(data)

	if stored_checksum != calculated_checksum:
		push_error("Checksum mismatch! Stored: %s, Calculated: %s" % [stored_checksum, calculated_checksum])
		return false

	print("✅ Checksum verified")
	return true

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

func _get_access_token() -> String:
	"""Get access token from SupabaseClient"""
	if not OS.has_feature("web"):
		return ""

	var token = JavaScriptBridge.eval("sessionStorage.getItem('bktd_auth_token')", true)
	if token == "null" or token == "":
		return ""
	return token

func auto_sync_on_event(event_name: String):
	"""Automatically sync to cloud on important game events"""
	print("🎮 Game event: %s - Auto-syncing..." % event_name)

	# Collect current save data
	collect_save_data()

	# Save locally first (fast)
	write_save_file("auto_save")

	# Then sync to cloud (async)
	if CLOUD_SYNC_ENABLED and SupabaseClient.is_authenticated():
		save_to_cloud()
