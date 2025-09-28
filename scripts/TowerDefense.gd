extends Node2D

@onready var map = $Map
@onready var path_layer = $Map/PathLayer
@onready var build_layer = $Map/BuildLayer
@onready var camera = $Camera2D

@onready var honey_label = $UI/GameUI/TopBar/ResourceDisplay/HoneyLabel
@onready var health_label = $UI/GameUI/TopBar/ResourceDisplay/HealthLabel
@onready var wave_label = $UI/GameUI/TopBar/ResourceDisplay/WaveLabel
@onready var start_wave_button = $UI/GameUI/Controls/StartWaveButton
@onready var place_tower_button = $UI/GameUI/Controls/PlaceTowerButton
@onready var back_button = $UI/GameUI/Controls/BackButton

var current_wave: int = 1
var player_health: int = 20
var honey: int = 100

# Tower placement
var tower_placer: TowerPlacer

# Wave management
var wave_manager: WaveManager

func _ready():
	GameManager.change_game_state(GameManager.GameState.TOWER_DEFENSE)

	start_wave_button.pressed.connect(_on_start_wave_pressed)
	place_tower_button.pressed.connect(_on_place_tower_pressed)
	back_button.pressed.connect(_on_back_pressed)

	setup_basic_map()
	setup_tower_placer()
	setup_wave_manager()
	update_ui()

func setup_basic_map():
	# Create visual map using ColorRect nodes instead of TileMap for now
	create_visual_map()
	create_simple_path()

func create_simple_texture() -> ImageTexture:
	var image = Image.create(64, 32, false, Image.FORMAT_RGB8)

	# Grass tile (green)
	for x in range(32):
		for y in range(32):
			image.set_pixel(x, y, Color.GREEN)

	# Path tile (brown)
	for x in range(32, 64):
		for y in range(32):
			image.set_pixel(x, y, Color(0.6, 0.4, 0.2))

	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func create_visual_map():
	# Create a visible background grid using ColorRect nodes
	var map_background = Node2D.new()
	map_background.name = "MapBackground"
	add_child(map_background)

	# Create grass background
	for x in range(20):
		for y in range(15):
			var grass_tile = ColorRect.new()
			grass_tile.size = Vector2(32, 32)
			grass_tile.position = Vector2(x * 32, y * 32)
			grass_tile.color = Color(0.2, 0.6, 0.2)  # Green grass
			map_background.add_child(grass_tile)

	print("Visual map created with 20x15 grid")

func create_simple_path():
	# Create visible path
	var path_background = Node2D.new()
	path_background.name = "PathBackground"
	add_child(path_background)

	var path_points = []

	# Horizontal path in the middle (row 7)
	for x in range(20):
		var path_tile = ColorRect.new()
		path_tile.size = Vector2(32, 32)
		path_tile.position = Vector2(x * 32, 7 * 32)
		path_tile.color = Color(0.6, 0.4, 0.2)  # Brown path
		path_background.add_child(path_tile)

		# Store path points for enemy movement
		path_points.append(Vector2(x * 32 + 16, 7 * 32 + 16))

	# Store path for enemy movement
	set_meta("path_points", path_points)
	print("Path created with ", path_points.size(), " points")

func setup_wave_manager():
	wave_manager = WaveManager.new()
	add_child(wave_manager)

	# Set spawn point (start of path)
	var path_points = get_meta("path_points", [])
	if not path_points.is_empty():
		wave_manager.set_spawn_point(path_points[0])
		wave_manager.set_enemy_path(path_points)

	# Connect signals
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.enemy_spawned.connect(_on_enemy_spawned)
	wave_manager.all_waves_completed.connect(_on_all_waves_completed)

func _on_start_wave_pressed():
	if wave_manager.is_wave_in_progress():
		print("Wave already in progress!")
		return

	wave_manager.start_wave(current_wave)
	start_wave_button.disabled = true

func _on_place_tower_pressed():
	tower_placer.start_tower_placement("basic_shooter")

func _on_back_pressed():
	SceneManager.goto_main_menu()

func update_ui():
	honey_label.text = "Honey: " + str(GameManager.get_resource("honey"))
	health_label.text = "Health: " + str(player_health)
	wave_label.text = "Wave: " + str(current_wave)

func add_honey(amount: int):
	honey += amount
	update_ui()

func take_damage(amount: int):
	player_health -= amount
	update_ui()

	if player_health <= 0:
		game_over()

func setup_tower_placer():
	tower_placer = TowerPlacer.new()
	add_child(tower_placer)

	# Connect signals
	tower_placer.tower_placed.connect(_on_tower_placed)
	tower_placer.tower_placement_failed.connect(_on_tower_placement_failed)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			# Start placing basic shooter tower
			tower_placer.start_tower_placement("basic_shooter")

func _on_tower_placed(tower: Tower, position: Vector2):
	print("Tower placed successfully: " + tower.tower_name)
	update_ui()

func _on_tower_placement_failed(reason: String):
	print("Tower placement failed: " + reason)

func _on_wave_started(wave_number: int):
	print("Wave ", wave_number, " started!")

func _on_wave_completed(wave_number: int, enemies_killed: int):
	print("Wave ", wave_number, " completed! Killed ", enemies_killed, " enemies")
	current_wave += 1
	start_wave_button.disabled = false
	update_ui()

func _on_enemy_spawned(enemy: Enemy):
	print("Enemy spawned: ", enemy.enemy_name)

func _on_all_waves_completed():
	print("All waves completed! Victory!")
	# TODO: Show victory screen

func take_damage(damage: int):
	player_health -= damage
	update_ui()

	if player_health <= 0:
		game_over()

func game_over():
	print("Game Over!")
	# TODO: Show game over screen