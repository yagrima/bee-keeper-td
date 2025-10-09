extends Node
## EnvLoader - Loads environment variables from .env file
## Runs first before all other autoloads
## Priority: -1 (loads before SaveManager and SupabaseClient)

const ENV_FILE_PATH = "res://.env"

func _init():
	_load_env_file()

func _load_env_file():
	"""Load environment variables from .env file"""
	print("🔧 EnvLoader: Loading .env file...")
	
	var env_path = ENV_FILE_PATH
	if not FileAccess.file_exists(env_path):
		push_warning("⚠️ .env file not found at: %s" % env_path)
		push_warning("⚠️ Environment variables will not be loaded. See .env.example")
		return
	
	var file = FileAccess.open(env_path, FileAccess.READ)
	if not file:
		push_error("❌ Failed to open .env file!")
		return
	
	var line_count = 0
	var loaded_count = 0
	
	while not file.eof_reached():
		var line = file.get_line().strip_edges()
		line_count += 1
		
		# Skip empty lines and comments
		if line == "" or line.begins_with("#"):
			continue
		
		# Parse KEY=VALUE format
		if "=" in line:
			var parts = line.split("=", true, 1)
			if parts.size() == 2:
				var key = parts[0].strip_edges()
				var value = parts[1].strip_edges()
				
				# Remove quotes if present
				if value.begins_with('"') and value.ends_with('"'):
					value = value.substr(1, value.length() - 2)
				elif value.begins_with("'") and value.ends_with("'"):
					value = value.substr(1, value.length() - 2)
				
				# Set environment variable
				OS.set_environment(key, value)
				loaded_count += 1
				print("  ✅ Loaded: %s = %s..." % [key, value.substr(0, min(30, value.length()))])
	
	file.close()
	print("✅ EnvLoader: Loaded %d variables from %d lines" % [loaded_count, line_count])

func get_env(key: String, default: String = "") -> String:
	"""Get environment variable with fallback"""
	var value = OS.get_environment(key)
	if value == "":
		return default
	return value
