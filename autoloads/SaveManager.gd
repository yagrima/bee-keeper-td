extends Node

# =============================================================================
# SAVE MANAGER (REFACTORED)
# =============================================================================
# Main coordinator for the save system
# Delegates to component systems for specific responsibilities
#
# Architecture:
# - Component-based design (delegation pattern)
# - Minimal coupling between systems
# - Clear separation of concerns
# =============================================================================

signal save_completed(success: bool, message: String)
signal load_completed(success: bool, message: String)
signal cloud_sync_started()
signal cloud_sync_completed(success: bool)
signal conflict_detected(local_data: Dictionary, cloud_data: Dictionary)

# Component systems
var security: SaveSecurity
var data_collector: SaveDataCollector
var file_handler: SaveFileHandler
var cloud_sync: SaveCloudSync

# Save data state
var save_data: Dictionary = {}

# Auto-save settings
var auto_save_enabled: bool = true
var auto_save_interval: float = 60.0
var auto_save_timer: Timer

# Cloud sync settings (Feature-Flag)
var cloud_sync_enabled: bool = false  # Disabled by default until Supabase is configured

func _ready():
	# Initialize component systems
	security = SaveSecurity.new()
	data_collector = SaveDataCollector.new(get_tree())
	file_handler = SaveFileHandler.new()
	cloud_sync = SaveCloudSync.new(self, security)
	
	# Connect cloud sync signals
	cloud_sync.cloud_sync_started.connect(func(): cloud_sync_started.emit())
	cloud_sync.cloud_sync_completed.connect(func(success): cloud_sync_completed.emit(success))
	cloud_sync.conflict_detected.connect(func(local, remote): conflict_detected.emit(local, remote))
	
	# Setup auto-save
	setup_auto_save()
	
	print("SaveManager initialized (refactored)")

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
	save_data = data_collector.collect_all_save_data()

	# Add checksum
	save_data["checksum"] = security.calculate_save_checksum(save_data)

	# Save to local file first (fast, always works)
	var success = file_handler.write_save_file(save_name, save_data)

	if not success:
		save_completed.emit(false, "Failed to save game")
		print("❌ Failed to save game: ", save_name)
		return false

	# Sync to cloud if authenticated AND enabled (async)
	if cloud_sync_enabled and SupabaseClient.is_authenticated():
		print("☁️ Syncing to cloud...")
		cloud_sync.save_to_cloud(save_data)  # Async, doesn't block
	elif not cloud_sync_enabled:
		print("ℹ️ Skipping cloud sync (feature disabled)")
	else:
		print("ℹ️ Skipping cloud sync (not authenticated)")

	save_completed.emit(true, "Game saved successfully")
	print("✅ Game saved successfully: ", save_name)

	return success

# =============================================================================
# LOAD SYSTEM
# =============================================================================

func load_game(save_name: String = "main") -> bool:
	"""
	Load a saved game (Cloud-First Strategy)
	Tries cloud first, fallback to local if not available
	"""
	print("📂 Loading game: ", save_name)

	# Cloud-First: Try loading from cloud if authenticated AND enabled
	if cloud_sync_enabled and SupabaseClient.is_authenticated():
		print("☁️ Attempting to load from cloud...")
		var cloud_data = await cloud_sync.load_from_cloud()

		if not cloud_data.is_empty():
			save_data = cloud_data
			apply_save_data()
			
			# Cache to local
			file_handler.write_save_file("cloud_cache", cloud_data)
			
			load_completed.emit(true, "Game loaded from cloud")
			print("✅ Game loaded from cloud")
			return true
		else:
			print("ℹ️ No cloud save found, trying local...")

	# Fallback: Load from local file
	save_data = file_handler.read_save_file(save_name)

	if not save_data.is_empty():
		# Verify checksum
		if not security.verify_save_checksum(save_data):
			push_warning("Save data checksum verification failed")
		
		apply_save_data()
		load_completed.emit(true, "Game loaded from local file")
		print("✅ Game loaded from local file: ", save_name)
		return true
	else:
		load_completed.emit(false, "Failed to load game")
		print("❌ Failed to load game: ", save_name)
		return false

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
# FILE MANAGEMENT
# =============================================================================

func get_save_files() -> Array[String]:
	"""Get list of available save files"""
	return file_handler.get_save_files()

func delete_save_file(save_name: String) -> bool:
	"""Delete a save file"""
	return file_handler.delete_save_file(save_name)

func save_file_exists(save_name: String) -> bool:
	"""Check if a save file exists"""
	return file_handler.save_file_exists(save_name)

func get_save_file_info(save_name: String) -> Dictionary:
	"""Get information about a save file"""
	return file_handler.get_save_file_info(save_name)

# =============================================================================
# CONFIGURATION
# =============================================================================

func save_config():
	"""Save game configuration"""
	var config_data = {
		"hotkeys": HotkeyManager.get_all_hotkeys(),
		"auto_save_enabled": auto_save_enabled,
		"auto_save_interval": auto_save_interval
	}
	file_handler.save_config(config_data)

func load_config():
	"""Load game configuration"""
	if not file_handler:
		print("⚠️ file_handler not initialized yet")
		return
	
	var config_data = file_handler.load_config()
	
	if config_data.is_empty():
		print("No configuration found, using defaults")
		return
	
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
	return file_handler.export_save_data(save_data)

func import_save_data(json_string: String) -> bool:
	"""Import save data from JSON string"""
	var imported_data = file_handler.import_save_data(json_string)
	
	if imported_data.is_empty():
		return false
	
	save_data = imported_data
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
# CLOUD SYNC
# =============================================================================

func sync_save() -> bool:
	"""Intelligent sync: Compare local and cloud"""
	var synced_data = await cloud_sync.sync_save(save_data)
	
	if not synced_data.is_empty():
		save_data = synced_data
		apply_save_data()
		file_handler.write_save_file("cloud_cache", synced_data)
		return true
	
	return false

func auto_sync_on_event(event_name: String):
	"""Automatically sync to cloud on important game events"""
	save_data = data_collector.collect_all_save_data()
	save_data["checksum"] = security.calculate_save_checksum(save_data)
	
	# Save locally first
	file_handler.write_save_file("auto_save", save_data)
	
	# Then sync to cloud (async)
	if cloud_sync_enabled and SupabaseClient.is_authenticated():
		cloud_sync.auto_sync_on_event(event_name, save_data)
