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
	# Create map background in UI layer, centered in window
	var ui_canvas = $UI

	# Calculate center position for 640x480 map in 1920x1080 window
	var window_size = get_viewport().get_visible_rect().size
	var map_size = Vector2(640, 480)  # 20*32 x 15*32
	var center_offset = (window_size - map_size) / 2

	# Create a single large background first
	var map_background = ColorRect.new()
	map_background.name = "MapBackground"
	map_background.size = map_size
	map_background.position = center_offset
	map_background.color = Color(0.2, 0.6, 0.2)  # Green grass
	map_background.z_index = -10  # Behind everything else
	ui_canvas.add_child(map_background)

	# Store map offset for tower placement
	set_meta("map_offset", center_offset)

	print("Visual map created in UI: ", map_background.size, " at ", map_background.position)
	print("Map centered with offset: ", center_offset)

func create_simple_path():
	# Create path in UI layer, adjusted for centered map
	var ui_canvas = $UI
	var map_offset = get_meta("map_offset", Vector2.ZERO)

	# Create visible path as one large rectangle
	var path_rect = ColorRect.new()
	path_rect.name = "PathBackground"
	path_rect.size = Vector2(640, 32)  # Full width, one tile height
	path_rect.position = Vector2(map_offset.x, map_offset.y + 7 * 32)  # Row 7, adjusted for center
	path_rect.color = Color(0.6, 0.4, 0.2)  # Brown path
	path_rect.z_index = -5  # Above map background but below other UI
	ui_canvas.add_child(path_rect)

	var path_points = []

	# Create path points for enemy movement (world coordinates, not UI coordinates)
	for x in range(20):
		path_points.append(Vector2(x * 32 + 16, 7 * 32 + 16))

	# Store path for enemy movement
	set_meta("path_points", path_points)
	print("Path created in UI: ", path_rect.size, " at ", path_rect.position)
	print("Path points: ", path_points.size(), " points from ", path_points[0], " to ", path_points[-1])

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


func game_over():
	print("Game Over!")
	# TODO: Show game over screen