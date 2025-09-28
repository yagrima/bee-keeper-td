extends Node

signal game_state_changed(new_state)
signal resources_changed(resource_type, amount)

enum GameState {
	MAIN_MENU,
	SETTLEMENT,
	TOWER_DEFENSE,
	PAUSED
}

var current_state: GameState = GameState.MAIN_MENU
var player_data: PlayerData

class PlayerData:
	var account_level: int = 1
	var honey: int = 100
	var honeygems: int = 0
	var wax: int = 50
	var wood: int = 0

	var buildings: Dictionary = {}
	var towers: Array = []
	var soldiers: Array = []

	func _init():
		# Initialize with starting resources
		pass

func _ready():
	player_data = PlayerData.new()
	print("GameManager initialized")

func change_game_state(new_state: GameState):
	if current_state != new_state:
		current_state = new_state
		game_state_changed.emit(new_state)
		print("Game state changed to: ", GameState.keys()[new_state])

func add_resource(resource_type: String, amount: int):
	match resource_type:
		"honey":
			player_data.honey += amount
		"honeygems":
			player_data.honeygems += amount
		"wax":
			player_data.wax += amount
		"wood":
			player_data.wood += amount

	resources_changed.emit(resource_type, amount)

func get_resource(resource_type: String) -> int:
	match resource_type:
		"honey":
			return player_data.honey
		"honeygems":
			return player_data.honeygems
		"wax":
			return player_data.wax
		"wood":
			return player_data.wood
		_:
			return 0

func set_resource(resource_type: String, amount: int):
	match resource_type:
		"honey":
			player_data.honey = amount
		"honeygems":
			player_data.honeygems = amount
		"wax":
			player_data.wax = amount
		"wood":
			player_data.wood = amount
		_:
			print("Unknown resource type: ", resource_type)
			return
	
	resources_changed.emit(resource_type, amount)
	print("Set ", resource_type, " to ", amount)

func save_game(save_name: String = "main") -> bool:
	"""Save the current game state using SaveManager"""
	return SaveManager.save_game(save_name)

func load_game(save_name: String = "main") -> bool:
	"""Load a saved game using SaveManager"""
	return SaveManager.load_game(save_name)

func get_save_files() -> Array[String]:
	"""Get list of available save files"""
	return SaveManager.get_save_files()

func save_file_exists(save_name: String) -> bool:
	"""Check if a save file exists"""
	return SaveManager.save_file_exists(save_name)

func delete_save_file(save_name: String) -> bool:
	"""Delete a save file"""
	return SaveManager.delete_save_file(save_name)

func get_save_file_info(save_name: String) -> Dictionary:
	"""Get information about a save file"""
	return SaveManager.get_save_file_info(save_name)