extends Node

# Hotkey Management System
# Provides centralized hotkey configuration and dynamic tooltip updates

signal hotkey_changed(action: String, old_key: int, new_key: int)

# Default hotkey configuration
var hotkeys: Dictionary = {
	"place_tower": KEY_T,
	"start_wave": KEY_R,
	"cancel_action": KEY_ESCAPE,
	"pause_game": KEY_SPACE,
	"save_game": KEY_F5,
	"load_game": KEY_F9,
	"quick_save": KEY_F6,
	"quick_load": KEY_F7,
	"speed_toggle": KEY_Q
}

# Action names for display
var action_names: Dictionary = {
	"place_tower": "Place Tower",
	"start_wave": "Start Wave",
	"cancel_action": "Cancel",
	"pause_game": "Pause",
	"save_game": "Save Game",
	"load_game": "Load Game",
	"quick_save": "Quick Save",
	"quick_load": "Quick Load",
	"speed_toggle": "Speed Toggle"
}

func _ready():
	print("HotkeyManager initialized")
	load_hotkeys_from_config()

func get_hotkey(action: String) -> int:
	"""Get the current hotkey for an action"""
	return hotkeys.get(action, KEY_NONE)

func get_hotkey_name(action: String) -> String:
	"""Get the human-readable name of the hotkey for an action"""
	var key_code = get_hotkey(action)
	if key_code == KEY_NONE:
		return ""
	return OS.get_keycode_string(key_code)

func get_action_display_text(action: String) -> String:
	"""Get the action name with hotkey in parentheses"""
	var action_name = action_names.get(action, action)
	var hotkey_name = get_hotkey_name(action)

	if hotkey_name != "":
		return action_name + " (" + hotkey_name + ")"
	else:
		return action_name

func set_hotkey(action: String, new_key: int) -> bool:
	"""Set a new hotkey for an action"""
	if not action in hotkeys:
		print("Warning: Unknown action '", action, "'")
		return false

	# Check for conflicts
	var conflicting_action = get_action_for_key(new_key)
	if conflicting_action != "" and conflicting_action != action:
		print("Warning: Key ", OS.get_keycode_string(new_key), " is already assigned to ", conflicting_action)
		return false

	var old_key = hotkeys[action]
	hotkeys[action] = new_key

	print("Hotkey changed: ", action, " from ", OS.get_keycode_string(old_key), " to ", OS.get_keycode_string(new_key))
	hotkey_changed.emit(action, old_key, new_key)

	save_hotkeys_to_config()
	return true

func get_action_for_key(key_code: int) -> String:
	"""Find which action is assigned to a specific key"""
	for action in hotkeys:
		if hotkeys[action] == key_code:
			return action
	return ""

func is_hotkey_pressed(event: InputEvent, action: String) -> bool:
	"""Check if a specific hotkey action was pressed"""
	if not event or not event is InputEventKey or not event.pressed:
		return false

	var hotkey = get_hotkey(action)
	return event.keycode == hotkey

func get_all_hotkeys() -> Dictionary:
	"""Get a copy of all current hotkeys"""
	return hotkeys.duplicate()

func reset_to_defaults():
	"""Reset all hotkeys to default values"""
	hotkeys = {
		"place_tower": KEY_T,
		"start_wave": KEY_R,
		"cancel_action": KEY_ESCAPE,
		"pause_game": KEY_SPACE,
		"save_game": KEY_F5,
		"load_game": KEY_F9,
		"quick_save": KEY_F6,
		"quick_load": KEY_F7
	}

	save_hotkeys_to_config()

	# Emit change signals for all actions
	for action in hotkeys:
		hotkey_changed.emit(action, KEY_NONE, hotkeys[action])

func load_hotkeys_from_config():
	"""Load hotkeys from configuration file"""
	SaveManager.load_config()
	print("Hotkeys loaded from config")

func save_hotkeys_to_config():
	"""Save current hotkeys to configuration file"""
	SaveManager.save_config()
	print("Hotkeys saved to config: ", hotkeys)

func print_current_hotkeys():
	"""Debug function to print all current hotkeys"""
	print("Current hotkeys:")
	for action in hotkeys:
		print("  ", action, ": ", OS.get_keycode_string(hotkeys[action]))