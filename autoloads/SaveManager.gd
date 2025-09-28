extends Node

# Save System for Bee Keeper TD
# Handles saving and loading of game state, player data, and scene states

signal save_completed(success: bool, message: String)
signal load_completed(success: bool, message: String)

# Save file configuration
const SAVE_DIR = "user://saves/"
const SAVE_FILE = "savegame.save"
const CONFIG_FILE = "user://config.cfg"

# Save data structure
var save_data: Dictionary = {}

# Auto-save settings
var auto_save_enabled: bool = true
var auto_save_interval: float = 60.0  # seconds
var auto_save_timer: Timer

func _ready():
	# Create save directory if it doesn't exist
	create_save_directory()
	
	# Setup auto-save timer
	setup_auto_save()
	
	print("SaveManager initialized")

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
	"""Save the current game state"""
	print("Saving game: ", save_name)
	
	# Collect all save data
	collect_save_data()
	
	# Save to file
	var success = write_save_file(save_name)
	
	if success:
		save_completed.emit(true, "Game saved successfully")
		print("Game saved successfully: ", save_name)
	else:
		save_completed.emit(false, "Failed to save game")
		print("Failed to save game: ", save_name)
	
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
	"""Load a saved game"""
	print("Loading game: ", save_name)
	
	# Load from file
	var success = read_save_file(save_name)
	
	if success:
		# Apply loaded data
		apply_save_data()
		load_completed.emit(true, "Game loaded successfully")
		print("Game loaded successfully: ", save_name)
	else:
		load_completed.emit(false, "Failed to load game")
		print("Failed to load game: ", save_name)
	
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
