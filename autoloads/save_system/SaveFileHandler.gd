class_name SaveFileHandler
extends RefCounted

# =============================================================================
# SAVE FILE HANDLER
# =============================================================================
# Handles local file operations for save system
# - Write/read save files
# - File management (list, delete, check existence)
# - Import/export functionality
# =============================================================================

const SAVE_DIR = "user://saves/"
const CONFIG_FILE = "user://config.cfg"

func _init():
	create_save_directory()

func create_save_directory():
	"""Create the save directory if it doesn't exist"""
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.open("user://").make_dir_recursive("saves")
		print("Created save directory: ", SAVE_DIR)

func write_save_file(save_name: String, data: Dictionary) -> bool:
	"""Write save data to file"""
	var file_path = SAVE_DIR + save_name + ".save"
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		print("Error: Could not open save file for writing: ", file_path)
		return false
	
	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	
	print("Save file written: ", file_path)
	return true

func read_save_file(save_name: String) -> Dictionary:
	"""Read save data from file"""
	var file_path = SAVE_DIR + save_name + ".save"
	
	if not FileAccess.file_exists(file_path):
		print("Error: Save file does not exist: ", file_path)
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("Error: Could not open save file for reading: ", file_path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("Error: Failed to parse save file JSON")
		return {}
	
	print("Save file loaded: ", file_path)
	return json.data

func get_save_files() -> Array[String]:
	"""Get list of all save files"""
	var save_files: Array[String] = []
	
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		return save_files
	
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".save"):
				save_files.append(file_name.get_basename())
			file_name = dir.get_next()
		
		dir.list_dir_end()
	
	return save_files

func delete_save_file(save_name: String) -> bool:
	"""Delete a save file"""
	var file_path = SAVE_DIR + save_name + ".save"
	
	if not FileAccess.file_exists(file_path):
		print("Error: Save file does not exist: ", file_path)
		return false
	
	DirAccess.remove_absolute(file_path)
	print("Save file deleted: ", file_path)
	return true

func save_file_exists(save_name: String) -> bool:
	"""Check if a save file exists"""
	var file_path = SAVE_DIR + save_name + ".save"
	return FileAccess.file_exists(file_path)

func get_save_file_info(save_name: String) -> Dictionary:
	"""Get information about a save file"""
	var file_path = SAVE_DIR + save_name + ".save"
	
	if not FileAccess.file_exists(file_path):
		return {}
	
	var data = read_save_file(save_name)
	
	if data.is_empty():
		return {}
	
	return {
		"name": save_name,
		"timestamp": data.get("timestamp", 0),
		"version": data.get("version", "unknown"),
		"game_state": data.get("game_state", GameManager.GameState.MAIN_MENU),
		"player_level": data.get("player_data", {}).get("account_level", 1),
		"honey": data.get("player_data", {}).get("honey", 0)
	}

func export_save_data(data: Dictionary) -> String:
	"""Export save data as JSON string"""
	return JSON.stringify(data, "\t")

func import_save_data(json_string: String) -> Dictionary:
	"""Import save data from JSON string"""
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		print("Error: Failed to parse JSON string")
		return {}
	
	return json.data

func save_config(config_data: Dictionary):
	"""Save configuration file"""
	var config = ConfigFile.new()
	
	for section in config_data:
		for key in config_data[section]:
			config.set_value(section, key, config_data[section][key])
	
	var error = config.save(CONFIG_FILE)
	if error != OK:
		print("Error saving config: ", error)
	else:
		print("Config saved successfully")

func load_config() -> Dictionary:
	"""Load configuration file"""
	var config = ConfigFile.new()
	var error = config.load(CONFIG_FILE)
	
	if error != OK:
		print("No config file found or error loading config")
		return {}
	
	var config_data = {}
	for section in config.get_sections():
		config_data[section] = {}
		for key in config.get_section_keys(section):
			config_data[section][key] = config.get_value(section, key)
	
	return config_data
