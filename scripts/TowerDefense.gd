extends Node2D

# =============================================================================
# TOWER DEFENSE MAIN CONTROLLER (REFACTORED)
# =============================================================================
# Main coordinator for the Tower Defense game scene
# Delegates to component systems for specific responsibilities
# 
# Architecture:
# - Component-based design (delegation pattern)
# - Minimal coupling between systems
# - Clear separation of concerns
# =============================================================================

# =============================================================================
# COMPONENT SYSTEMS
# =============================================================================
var save_system: TDSaveSystem
var wave_controller: TDWaveController
var ui_manager: TDUIManager
var metaprogression: TDMetaprogression
var input_handler: TDInputHandler
var tower_selection: TDTowerSelection
var debug_system: TDDebug

# =============================================================================
# SCENE NODE REFERENCES
# =============================================================================
@onready var map = $Map
@onready var path_layer = $Map/PathLayer
@onready var build_layer = $Map/BuildLayer
@onready var camera = $Camera2D

# UI Elements
@onready var honey_label = $UI/GameUI/TopBar/ResourceDisplay/HoneyPanel/HoneyLabel
@onready var health_label = $UI/GameUI/TopBar/ResourceDisplay/HealthPanel/HealthLabel
@onready var wave_label = $UI/GameUI/TopBar/ResourceDisplay/WavePanel/WaveLabel
@onready var start_wave_button = $UI/GameUI/ControlsPanel/Controls/StartWaveButton
@onready var back_button = $UI/GameUI/TopBar/ResourceDisplay/BackButton
@onready var speed_button: Button

# =============================================================================
# PUBLIC VARIABLES
# =============================================================================
var current_wave: int = 0
var player_health: int = 20
var honey: int = 100
var speed_mode: int = 0  # 0 = normal, 1 = 2x, 2 = 3x

# Tower placement
var tower_placer: TowerPlacer
var current_tower_type: String = "stinger"
var available_tower_types: Array[String] = ["stinger", "propolis_bomber", "nectar_sprayer", "lightning_flower"]

# UI References (created dynamically)
var wave_composition_label: Label
var wave_countdown_label: Label
var place_tower_button: Button

# Individual tower buttons
var stinger_button: Button
var propolis_bomber_button: Button
var nectar_sprayer_button: Button
var lightning_flower_button: Button

# State flags
var is_in_tower_placement: bool = false

# Debug (delegated to debug_system)
var debug_label: Label = null
var is_development_build: bool = false

# Wave management
var wave_manager: WaveManager
var wave_countdown_timer: Timer
var countdown_seconds: float = 0.0

# Cursor management
var cursor_timer: Timer
var is_hovering_ui: bool = false

# =============================================================================
# LIFECYCLE METHODS
# =============================================================================

func _ready():
	# Initialize component systems FIRST
	save_system = TDSaveSystem.new(self)
	wave_controller = TDWaveController.new(self)
	ui_manager = TDUIManager.new(self)
	metaprogression = TDMetaprogression.new(self)
	input_handler = TDInputHandler.new(self)
	tower_selection = TDTowerSelection.new(self)
	debug_system = TDDebug.new(self)

	# Set up ui_manager references
	ui_manager.honey_label = honey_label
	ui_manager.health_label = health_label
	ui_manager.wave_label = wave_label
	ui_manager.start_wave_button = start_wave_button
	ui_manager.place_tower_button = place_tower_button

	# Set game state
	GameManager.change_game_state(GameManager.GameState.TOWER_DEFENSE)

	# Initialize debug system
	is_development_build = debug_system.check_development_mode()
	input_handler.is_development_build = is_development_build
	
	if is_development_build:
		debug_label = debug_system.create_debug_overlay()

	# Reset game state for new game
	reset_game_state()

	# Connect button signals
	if start_wave_button:
		start_wave_button.pressed.connect(_on_start_wave_pressed)
	if place_tower_button:
		place_tower_button.pressed.connect(func(): _on_place_tower_pressed())
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

	# Set up scene
	setup_basic_map()
	setup_wave_manager()
	setup_tower_placer()
	setup_cursor_timer()

	# Connect global signals
	if HotkeyManager:
		HotkeyManager.hotkey_changed.connect(_on_hotkey_changed)
	if GameManager:
		GameManager.resources_changed.connect(_on_resources_changed)

	# Set up save system
	save_system.check_for_pending_save_data()

	# Auto-save on exit
	tree_exiting.connect(_on_tree_exiting)

	# Initial UI update
	update_ui()

func _input(event):
	"""Delegate input handling to input_handler component"""
	input_handler.handle_input(event)

func _process(delta):
	"""Update mouse-following range indicator for metaprogression"""
	if metaprogression.picked_up_tower and tower_selection.range_indicator:
		var mouse_pos = get_global_mouse_position()
		tower_selection.update_mouse_position(mouse_pos)
		metaprogression.picked_up_tower.global_position = mouse_pos

# =============================================================================
# SCENE SETUP
# =============================================================================

func setup_basic_map():
	"""Set up basic map visuals"""
	var map_size = Vector2(640, 480)
	var window_size = get_viewport().get_visible_rect().size
	var map_offset = (window_size - map_size) / 2

	# Create visual map
	create_visual_map()

	# Create simple path
	create_simple_path()

	# Create grid overlay for debugging
	var ui_canvas = $UI
	create_grid_overlay(ui_canvas, map_offset, map_size)

	# Create path segments visualization
	create_path_segments(ui_canvas, map_offset)

func create_simple_texture() -> ImageTexture:
	"""Create a simple colored texture"""
	var image = Image.create(32, 32, false, Image.FORMAT_RGB8)
	image.fill(Color(0.2, 0.6, 0.2))
	return ImageTexture.create_from_image(image)

func create_visual_map():
	"""Create visual representation of the map"""
	var map_size = Vector2(640, 480)
	var map_visual = ColorRect.new()
	map_visual.size = map_size
	map_visual.color = Color(0.15, 0.5, 0.15)
	map_visual.position = Vector2.ZERO
	build_layer.add_child(map_visual)

	var border = ColorRect.new()
	border.size = map_size
	border.color = Color.TRANSPARENT
	border.position = Vector2.ZERO
	var style = StyleBoxFlat.new()
	style.border_color = Color(0.4, 0.3, 0.2)
	style.set_border_width_all(2)

func create_grid_overlay(ui_canvas: CanvasLayer, offset: Vector2, map_size: Vector2):
	"""Create grid overlay for debugging"""
	var grid = Node2D.new()
	grid.name = "GridOverlay"
	grid.position = offset
	ui_canvas.add_child(grid)

	var grid_size = 32
	var grid_color = Color(0.0, 0.0, 0.0, 0.2)

	for x in range(0, int(map_size.x) + 1, grid_size):
		var line = Line2D.new()
		line.add_point(Vector2(x, 0))
		line.add_point(Vector2(x, map_size.y))
		line.default_color = grid_color
		line.width = 1
		grid.add_child(line)

	for y in range(0, int(map_size.y) + 1, grid_size):
		var line = Line2D.new()
		line.add_point(Vector2(0, y))
		line.add_point(Vector2(map_size.x, y))
		line.default_color = grid_color
		line.width = 1
		grid.add_child(line)

func create_simple_path():
	"""Create a simple path for enemies"""
	var path = Path2D.new()
	path.name = "EnemyPath"
	var curve = Curve2D.new()

	curve.add_point(Vector2(-50, 240))
	curve.add_point(Vector2(160, 240))
	curve.add_point(Vector2(160, 120))
	curve.add_point(Vector2(480, 120))
	curve.add_point(Vector2(480, 360))
	curve.add_point(Vector2(690, 360))

	path.curve = curve
	path_layer.add_child(path)

func create_path_segments(ui_canvas: CanvasLayer, map_offset: Vector2):
	"""Create visual representation of path segments"""
	var path = path_layer.get_node_or_null("EnemyPath")
	if not path:
		return

	var segments = Node2D.new()
	segments.name = "PathSegments"
	segments.position = map_offset
	ui_canvas.add_child(segments)

	var curve = path.curve
	var sample_points = []
	var num_samples = 100

	for i in range(num_samples + 1):
		var t = float(i) / num_samples
		var point = curve.sample_baked(curve.get_baked_length() * t)
		sample_points.append(point)

	var line = Line2D.new()
	line.points = PackedVector2Array(sample_points)
	line.default_color = Color(0.8, 0.6, 0.4, 0.8)
	line.width = 24
	segments.add_child(line)

func setup_wave_manager():
	"""Set up wave manager"""
	wave_manager = WaveManager.new()
	add_child(wave_manager)

	var path = path_layer.get_node_or_null("EnemyPath")
	if path:
		wave_manager.enemy_path = path
	wave_manager.wave_completed.connect(wave_controller._on_wave_completed)
	wave_manager.enemy_reached_end.connect(_on_enemy_reached_end)
	wave_manager.enemy_died.connect(_on_enemy_died)

	print("✅ Wave manager created")

	wave_countdown_timer = Timer.new()
	wave_countdown_timer.name = "WaveCountdownTimer"
	wave_countdown_timer.wait_time = 1.0
	wave_countdown_timer.timeout.connect(_on_wave_countdown_timer_timeout)
	add_child(wave_countdown_timer)

func setup_tower_placer():
	"""Set up tower placer"""
	tower_placer = TowerPlacer.new()
	tower_placer.build_layer = build_layer
	tower_placer.path_layer = path_layer
	add_child(tower_placer)

	tower_placer.tower_placed.connect(_on_tower_placed)
	tower_placer.tower_placement_failed.connect(_on_tower_placement_failed)
	tower_placer.placement_mode_changed.connect(_on_placement_mode_changed)

func setup_cursor_timer():
	"""Set up cursor timer for UI hover detection"""
	cursor_timer = Timer.new()
	cursor_timer.wait_time = 0.3
	cursor_timer.one_shot = true
	cursor_timer.timeout.connect(_on_cursor_timer_timeout)
	add_child(cursor_timer)

# =============================================================================
# PUBLIC METHODS (Thin delegation layer)
# =============================================================================

func handle_tower_click(click_position: Vector2):
	"""Delegate to tower_selection component"""
	tower_selection.handle_tower_click(click_position)

func clear_tower_selection():
	"""Delegate to tower_selection component"""
	tower_selection.clear_tower_selection()

func show_tower_range_at_mouse_position(tower: Tower):
	"""Delegate to tower_selection component"""
	tower_selection.show_tower_range_at_mouse_position(tower)

func handle_tower_hotkey(tower_type: String, tower_name: String):
	"""Handle tower placement hotkeys"""
	print("\n=== TOWER HOTKEY PRESSED ===")
	print("Tower Type: ", tower_type)
	print("Tower Name: ", tower_name)

	var tower_cost = get_tower_cost(tower_type)
	var current_honey = GameManager.get_resource("honey")

	if current_honey < tower_cost:
		print("❌ Not enough honey! Need: ", tower_cost, ", Have: ", current_honey)
		ui_manager.show_insufficient_honey_dialog(tower_cost, current_honey)
		return

	current_tower_type = tower_type
	ui_manager.update_button_selection()
	tower_placer.start_tower_placement(current_tower_type)

func get_tower_cost(tower_type: String) -> int:
	"""Get the cost of a tower type"""
	match tower_type:
		"stinger":
			return 20
		"propolis_bomber":
			return 45
		"nectar_sprayer":
			return 30
		"lightning_flower":
			return 35
		"basic_shooter":
			return 25
		"piercing_shooter":
			return 35
		_:
			return 25

func update_ui():
	"""Update UI elements"""
	if honey_label:
		honey_label.text = str(GameManager.get_resource("honey"))
	if health_label:
		health_label.text = str(player_health)

	wave_controller.update_wave_ui()

func add_honey(amount: int):
	"""Add honey to player resources"""
	GameManager.add_resource("honey", amount)

func take_damage(amount: int):
	"""Player takes damage"""
	player_health -= amount
	update_ui()
	if player_health <= 0:
		trigger_game_over()

func trigger_game_over():
	"""Trigger game over"""
	ui_manager.show_game_over_screen()

func reset_game_state():
	"""Reset all game state to initial values"""
	print("Resetting game state for new game")

	player_health = 20
	current_wave = 0
	GameManager.set_resource("honey", 100)

	if speed_mode != 0:
		speed_mode = 0
		Engine.time_scale = 1.0
		if ui_manager:
			ui_manager.update_speed_button_text()

	print("Game state reset complete")

func show_victory_screen():
	"""Delegate to UI manager"""
	ui_manager.show_victory_screen()

# =============================================================================
# SIGNAL HANDLERS
# =============================================================================

func _on_start_wave_pressed():
	"""Delegate to wave controller"""
	wave_controller._on_start_wave_pressed()

func _on_place_tower_pressed(tower_type: String = ""):
	"""Handle place tower button press"""
	if tower_type.is_empty():
		tower_type = current_tower_type

	var tower_cost = get_tower_cost(tower_type)
	var current_honey = GameManager.get_resource("honey")

	if current_honey < tower_cost:
		ui_manager.show_insufficient_honey_dialog(tower_cost, current_honey)
		return

	current_tower_type = tower_type
	tower_placer.start_tower_placement(current_tower_type)

func _on_back_pressed():
	"""Handle back button press"""
	SceneManager.change_scene("res://scenes/main/Main.tscn")

func _on_tower_placed(tower: Tower, position: Vector2):
	"""Handle tower placement"""
	print("Tower placed successfully: " + tower.tower_name)
	tower_selection.on_tower_placed()
	update_ui()

	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(tower_selection.on_tower_placement_complete)

func _on_tower_placement_failed(reason: String):
	"""Handle tower placement failure"""
	print("Tower placement failed: " + reason)

func _on_placement_mode_changed(is_active: bool):
	"""Handle placement mode change"""
	if place_tower_button:
		place_tower_button.button_pressed = is_active
	is_in_tower_placement = is_active

	if not is_active:
		tower_selection.is_placing_tower = false
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_enemy_reached_end(enemy: Enemy):
	"""Handle enemy reaching end of path"""
	take_damage(enemy.damage)
	enemy.queue_free()

func _on_enemy_died(enemy: Enemy):
	"""Handle enemy death"""
	add_honey(enemy.honey_reward)

func _on_speed_button_pressed():
	"""Handle speed button press"""
	var old_mode = speed_mode
	speed_mode = (speed_mode + 1) % 3
	apply_speed_mode()
	
	if ui_manager:
		ui_manager.update_speed_button_text()

func apply_speed_mode():
	"""Apply current speed mode"""
	match speed_mode:
		0:
			Engine.time_scale = 1.0
			print("Speed mode: Normal (1x)")
		1:
			Engine.time_scale = 2.0
			print("Speed mode: Double (2x)")
		2:
			Engine.time_scale = 3.0
			print("Speed mode: Triple (3x)")

func _on_cursor_timer_timeout():
	"""Handle cursor timer timeout"""
	if is_hovering_ui and is_in_tower_placement:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_start_wave_button_mouse_entered():
	"""Handle mouse entering start wave button"""
	if is_in_tower_placement:
		is_hovering_ui = true
		cursor_timer.start()

func _on_start_wave_button_mouse_exited():
	"""Handle mouse exiting start wave button"""
	if is_in_tower_placement:
		is_hovering_ui = false
		cursor_timer.stop()
		Input.set_default_cursor_shape(Input.CURSOR_CROSS)

func _on_hotkey_changed(action: String, old_key: int, new_key: int):
	"""Handle hotkey change"""
	print("Hotkey changed for ", action, " - updating button texts")
	ui_manager.update_button_texts()

func _on_resources_changed(resource_type: String, amount: int):
	"""Handle resource changes"""
	if resource_type == "honey":
		update_ui()
		print("Honey changed by: %d (Total: %d)" % [amount, GameManager.get_resource("honey")])

func _on_tree_exiting():
	"""Auto-save before leaving"""
	print("👋 Exiting Tower Defense, auto-saving...")
	save_system.auto_save_game("Exiting Tower Defense")

func _on_wave_countdown_timer_timeout():
	"""Delegate to wave controller"""
	wave_controller._on_wave_countdown_timer_timeout()

# =============================================================================
# INTEGRATION TESTING (Development only)
# =============================================================================

func run_lightning_flower_integration_test():
	"""Delegate to debug system"""
	if is_development_build:
		debug_system.run_lightning_flower_integration_test()

# =============================================================================
# LEGACY COMPATIBILITY (Empty stubs for metaprogression system)
# =============================================================================

func start_tower_following_mouse():
	"""Legacy: Used by metaprogression system"""
	pass

func stop_tower_following_mouse():
	"""Legacy: Used by metaprogression system"""
	pass
