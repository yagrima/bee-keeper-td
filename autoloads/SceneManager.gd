extends Node

var current_scene: Node = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func goto_scene(path: String):
	call_deferred("_deferred_goto_scene", path)

func _deferred_goto_scene(path: String):
	if current_scene:
		current_scene.free()

	var new_scene = ResourceLoader.load(path)
	if new_scene:
		current_scene = new_scene.instantiate()
		get_tree().root.add_child(current_scene)
		get_tree().current_scene = current_scene
		print("Scene changed to: ", path)
	else:
		print("Failed to load scene: ", path)

func goto_main_menu():
	GameManager.change_game_state(GameManager.GameState.MAIN_MENU)
	goto_scene("res://scenes/main/Main.tscn")

func goto_settlement():
	GameManager.change_game_state(GameManager.GameState.SETTLEMENT)
	goto_scene("res://scenes/meta/Settlement.tscn")

func goto_tower_defense():
	GameManager.change_game_state(GameManager.GameState.TOWER_DEFENSE)
	goto_scene("res://scenes/main/TowerDefense.tscn")