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

func save_game():
	# TODO: Implement save system
	print("Game saved")

func load_game():
	# TODO: Implement load system
	print("Game loaded")