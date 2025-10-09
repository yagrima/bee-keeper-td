extends Node2D

# Component systems
var save_system: TDSaveSystem
var wave_controller: TDWaveController
var ui_manager: TDUIManager
var metaprogression: TDMetaprogression

@onready var map = $Map
@onready var path_layer = $Map/PathLayer
@onready var build_layer = $Map/BuildLayer
@onready var camera = $Camera2D

@onready var honey_label = $UI/GameUI/TopBar/ResourceDisplay/HoneyPanel/HoneyLabel
@onready var health_label = $UI/GameUI/TopBar/ResourceDisplay/HealthPanel/HealthLabel
@onready var wave_label = $UI/GameUI/TopBar/ResourceDisplay/WavePanel/WaveLabel
@onready var start_wave_button = $UI/GameUI/ControlsPanel/Controls/StartWaveButton
@onready var back_button = $UI/GameUI/TopBar/ResourceDisplay/BackButton

# Wave labels are created dynamically in TDUIManager
var wave_composition_label: Label
var wave_countdown_label: Label

# Reference for dynamically created buttons
var place_tower_button: Button
@onready var speed_button: Button

var current_wave: int = 0  # 0 = no wave started yet, 1+ = wave number
var player_health: int = 20
var honey: int = 100
var speed_mode: int = 0  # 0 = normal, 1 = 2x, 2 = 3x

# Tower placement
var tower_placer: TowerPlacer
var current_tower_type: String = "stinger"
var available_tower_types: Array[String] = ["stinger", "propolis_bomber", "nectar_sprayer", "lightning_flower"]

# Debug overlay for keyboard events (development only)
var debug_label: Label = null
var debug_messages: Array[String] = []
const MAX_DEBUG_MESSAGES = 25  # Increased for more verbose output
var is_development_build: bool = false  # Detected automatically

# Individual tower buttons
var stinger_button: Button
var propolis_bomber_button: Button
var nectar_sprayer_button: Button
var lightning_flower_button: Button

# Wave management
var wave_manager: WaveManager

# Cursor management
var cursor_timer: Timer
var is_hovering_ui: bool = false
var is_in_tower_placement: bool = false

# Tower selection and range display
var selected_tower: Tower = null
var range_indicator: Node2D = null
var is_placing_tower: bool = false

# Wave countdown timer
var wave_countdown_timer: Timer
var countdown_seconds: float = 0.0

# Metaprogression system (references maintained for backward compatibility)
var metaprogression_towers: Array[Tower] = []
var picked_up_tower: Tower = null

func _ready():
	# Initialize component systems FIRST
	save_system = TDSaveSystem.new(self)
	wave_controller = TDWaveController.new(self)
	ui_manager = TDUIManager.new(self)
	metaprogression = TDMetaprogression.new(self)

	# Set up ui_manager references
	ui_manager.honey_label = honey_label
	ui_manager.health_label = health_label
	ui_manager.wave_label = wave_label
	ui_manager.start_wave_button = start_wave_button
	ui_manager.place_tower_button = place_tower_button

	GameManager.change_game_state(GameManager.GameState.TOWER_DEFENSE)

	# Check if we're in development mode
	check_development_mode()
	
	# Create debug overlay (development only)
	if is_development_build:
		create_debug_overlay()

	# Reset game state for new game
	reset_game_state()

	# Connect button signals with null checks
	if start_wave_button:
		start_wave_button.pressed.connect(_on_start_wave_pressed)
	if place_tower_button:
		place_tower_button.pressed.connect(_on_place_tower_pressed)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

	# Set button text with dynamic hotkey hints
	ui_manager.update_button_texts()

	# Connect to hotkey changes to update button texts
	HotkeyManager.hotkey_changed.connect(_on_hotkey_changed)

	# Connect to GameManager signals for real-time UI updates
	GameManager.resources_changed.connect(_on_resources_changed)

	# Connect mouse hover signals for cursor management
	if start_wave_button:
		start_wave_button.mouse_entered.connect(_on_start_wave_button_mouse_entered)
		start_wave_button.mouse_exited.connect(_on_start_wave_button_mouse_exited)

	# Connect exit signal for auto-save
	tree_exiting.connect(_on_tree_exiting)

	setup_basic_map()
	setup_tower_placer()
	setup_wave_manager()
	setup_cursor_timer()
	ui_manager.setup_wave_composition_ui()
	ui_manager.setup_wave_countdown_ui()
	ui_manager.setup_individual_tower_buttons()
	add_debug_message("About to call setup_speed_button()...")
	ui_manager.setup_speed_button()
	add_debug_message("setup_speed_button() completed")
	
	# CRITICAL CHECK: Verify button exists after setup
	if ui_manager.speed_button:
		add_debug_message("✅ speed_button EXISTS after setup")
	else:
		add_debug_message("❌ speed_button is NULL after setup!")
	
	metaprogression.setup_metaprogression_fields()

	# Set up UI manager references after components are created
	# NOTE: wave_composition_label and wave_countdown_label are created in setup_wave_composition_ui/setup_wave_countdown_ui
	# and their references are already stored in ui_manager, so we don't need to set them here
	ui_manager.wave_countdown_timer = wave_countdown_timer
	ui_manager.stinger_button = stinger_button
	ui_manager.propolis_bomber_button = propolis_bomber_button
	ui_manager.nectar_sprayer_button = nectar_sprayer_button
	ui_manager.lightning_flower_button = lightning_flower_button
	# NOTE: speed_button is created dynamically in setup_speed_button(), not from scene tree

	update_ui()

	# Auto-load save data when entering the game
	save_system.auto_load_game()

	# Integration tests available via run_lightning_flower_integration_test() if needed


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
	var window_size = Vector2(get_viewport().get_visible_rect().size)
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

	# Create grid overlay
	create_grid_overlay(ui_canvas, center_offset, map_size)

	# Store map offset for tower placement
	set_meta("map_offset", center_offset)

	print("Visual map created in UI: ", map_background.size, " at ", map_background.position)
	print("Map centered with offset: ", center_offset)

func create_grid_overlay(ui_canvas: CanvasLayer, offset: Vector2, map_size: Vector2):
	# Create shader-based grid for perfect pixel rendering
	var grid_rect = ColorRect.new()
	grid_rect.name = "ShaderGrid"
	grid_rect.size = map_size
	grid_rect.position = offset
	grid_rect.z_index = 5

	# Create grid shader
	var shader_material = ShaderMaterial.new()
	var shader = Shader.new()
	shader.code = """
	shader_type canvas_item;

	uniform float grid_size : hint_range(1.0, 100.0) = 32.0;
	uniform vec4 grid_color : source_color = vec4(1.0, 1.0, 1.0, 0.8);
	uniform vec4 background_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);
	uniform float line_width : hint_range(0.5, 5.0) = 1.0;

	void fragment() {
		vec2 pixel_pos = UV * vec2(640.0, 480.0);

		// Check if we're on a grid line (every 32 pixels)
		vec2 grid_check = mod(pixel_pos, grid_size);

		// Simple check: if we're within line_width pixels of a grid boundary
		bool on_vertical_line = grid_check.x < line_width || grid_check.x > (grid_size - line_width);
		bool on_horizontal_line = grid_check.y < line_width || grid_check.y > (grid_size - line_width);

		if (on_vertical_line || on_horizontal_line) {
			COLOR = grid_color;
		} else {
			COLOR = background_color;
		}
	}
	"""

	shader_material.shader = shader
	shader_material.set_shader_parameter("grid_size", 32.0)
	shader_material.set_shader_parameter("grid_color", Color(1.0, 1.0, 1.0, 0.4))
	shader_material.set_shader_parameter("background_color", Color(0.0, 0.0, 0.0, 0.0))
	shader_material.set_shader_parameter("line_width", 1.5)

	grid_rect.material = shader_material
	ui_canvas.add_child(grid_rect)

	print("Created shader-based grid: ", map_size, " at ", offset)

func create_simple_path():
	# Create path in UI layer, adjusted for centered map
	var ui_canvas = $UI
	var map_offset = get_meta("map_offset", Vector2.ZERO)

	# Create path segments with four corners
	create_path_segments(ui_canvas, map_offset)

	var path_points: Array[Vector2] = []

	# Create path with four corners, none in first/last columns (0,19) or rows (0,14)
	# Start at first column, middle height
	path_points.append(Vector2(16, 7 * 32 + 16))  # Start point column 0, row 7

	# Go right to column 5 (first corner position)
	for x in range(1, 6):
		path_points.append(Vector2(x * 32 + 16, 7 * 32 + 16))

	# Corner 1 at (5, 7): Go down to row 11
	for y in range(8, 12):
		path_points.append(Vector2(5 * 32 + 16, y * 32 + 16))

	# Corner 2 at (5, 11): Go right to column 14
	for x in range(6, 15):
		path_points.append(Vector2(x * 32 + 16, 11 * 32 + 16))

	# Corner 3 at (14, 11): Go up to row 3
	for y in range(10, 2, -1):
		path_points.append(Vector2(14 * 32 + 16, y * 32 + 16))

	# Corner 4 at (14, 3): Go right to last column
	for x in range(15, 20):
		path_points.append(Vector2(x * 32 + 16, 3 * 32 + 16))

	# Store path for enemy movement
	set_meta("path_points", path_points)
	print("Path created with ", path_points.size(), " points from ", path_points[0], " to ", path_points[-1])

func create_path_segments(ui_canvas: CanvasLayer, map_offset: Vector2):
	var path_color = Color(0.6, 0.4, 0.2)  # Brown path color

	# Horizontal segment: row 7, columns 0-5
	var segment1 = ColorRect.new()
	segment1.size = Vector2(6 * 32, 32)  # 6 tiles wide, 1 tile high
	segment1.position = Vector2(map_offset.x + 0, map_offset.y + 7 * 32)
	segment1.color = path_color
	segment1.z_index = -5
	ui_canvas.add_child(segment1)

	# Vertical segment: column 5, rows 7-11
	var segment2 = ColorRect.new()
	segment2.size = Vector2(32, 5 * 32)  # 1 tile wide, 5 tiles high
	segment2.position = Vector2(map_offset.x + 5 * 32, map_offset.y + 7 * 32)
	segment2.color = path_color
	segment2.z_index = -5
	ui_canvas.add_child(segment2)

	# Horizontal segment: row 11, columns 5-14
	var segment3 = ColorRect.new()
	segment3.size = Vector2(10 * 32, 32)  # 10 tiles wide, 1 tile high
	segment3.position = Vector2(map_offset.x + 5 * 32, map_offset.y + 11 * 32)
	segment3.color = path_color
	segment3.z_index = -5
	ui_canvas.add_child(segment3)

	# Vertical segment: column 14, rows 3-11
	var segment4 = ColorRect.new()
	segment4.size = Vector2(32, 9 * 32)  # 1 tile wide, 9 tiles high
	segment4.position = Vector2(map_offset.x + 14 * 32, map_offset.y + 3 * 32)
	segment4.color = path_color
	segment4.z_index = -5
	ui_canvas.add_child(segment4)

	# Horizontal segment: row 3, columns 14-19
	var segment5 = ColorRect.new()
	segment5.size = Vector2(6 * 32, 32)  # 6 tiles wide, 1 tile high
	segment5.position = Vector2(map_offset.x + 14 * 32, map_offset.y + 3 * 32)
	segment5.color = path_color
	segment5.z_index = -5
	ui_canvas.add_child(segment5)

	# Start field (red-brown): column 0, row 7
	var start_field = ColorRect.new()
	start_field.size = Vector2(32, 32)  # 1 tile
	start_field.position = Vector2(map_offset.x + 0, map_offset.y + 7 * 32)
	start_field.color = Color(0.8, 0.3, 0.2)  # Red-brown color
	start_field.z_index = -4  # Above path but below other elements
	ui_canvas.add_child(start_field)

	# End field (green-brown): column 19, row 3
	var end_field = ColorRect.new()
	end_field.size = Vector2(32, 32)  # 1 tile
	end_field.position = Vector2(map_offset.x + 19 * 32, map_offset.y + 3 * 32)
	end_field.color = Color(0.5, 0.5, 0.2)  # More brown green-brown color
	end_field.z_index = -4  # Above path but below other elements
	ui_canvas.add_child(end_field)

func setup_wave_manager():
	wave_manager = WaveManager.new()
	add_child(wave_manager)

	# Set spawn point (start of path) - convert to UI coordinates
	var path_points = get_meta("path_points", [])
	var map_offset = get_meta("map_offset", Vector2.ZERO)
	if not path_points.is_empty():
		# Convert world coordinates to UI coordinates by adding map offset
		var ui_spawn_point = path_points[0] + map_offset
		var ui_path_points: Array[Vector2] = []
		for point in path_points:
			ui_path_points.append(point + map_offset)

		wave_manager.set_spawn_point(ui_spawn_point)
		wave_manager.set_enemy_path(ui_path_points)

	# Connect signals to wave controller
	wave_manager.wave_started.connect(wave_controller._on_wave_started)
	wave_manager.wave_completed.connect(wave_controller._on_wave_completed)
	wave_manager.enemy_spawned.connect(wave_controller._on_enemy_spawned)
	wave_manager.all_waves_completed.connect(wave_controller._on_all_waves_completed)

func _on_start_wave_pressed():
	if wave_manager.is_wave_in_progress():
		print("Wave already in progress!")
		return

	# Clear tower selection when starting wave
	clear_tower_selection()

	# Stop any existing auto wave timer and countdown
	wave_controller.stop_auto_wave_timer()

	# Increment wave BEFORE starting it
	current_wave += 1
	print("Starting wave %d" % current_wave)
	
	wave_manager.start_wave(current_wave)
	update_ui()  # Update UI immediately to show correct wave
	
	if start_wave_button:
		start_wave_button.disabled = true

func _on_place_tower_pressed(tower_type: String = ""):
	# Use the provided tower type, or fall back to current_tower_type
	var selected_type = tower_type if tower_type != "" else current_tower_type

	# Clear tower selection when starting tower placement
	clear_tower_selection()

	# Check if player has enough honey for the tower
	var tower_cost = get_tower_cost(selected_type)
	var current_honey = GameManager.get_resource("honey")

	if current_honey < tower_cost:
		ui_manager.show_insufficient_honey_dialog(tower_cost, current_honey)
		return

	# Set current tower type and start placement
	current_tower_type = selected_type
	ui_manager.update_button_selection()
	tower_placer.start_tower_placement(current_tower_type)

func _on_back_pressed():
	SceneManager.goto_main_menu()

func update_ui():
	ui_manager.update_ui()

func add_honey(amount: int):
	honey += amount
	update_ui()

func take_damage(amount: int):
	player_health -= amount
	update_ui()

	if player_health <= 0:
		trigger_game_over()

func trigger_game_over():
	print("Game Over! Player health reached 0")
	ui_manager.show_game_over_screen()

func setup_tower_placer():
	tower_placer = TowerPlacer.new()
	add_child(tower_placer)

	# Connect signals
	tower_placer.tower_placed.connect(_on_tower_placed)
	tower_placer.tower_placement_failed.connect(_on_tower_placement_failed)
	tower_placer.placement_mode_changed.connect(_on_placement_mode_changed)

func check_development_mode():
	"""Check if we're running in development mode"""
	is_development_build = (
		OS.is_debug_build() or  # Debug build
		OS.has_feature("debug") or  # Debug feature enabled
		OS.get_environment("GODOT_DEBUG") == "1" or  # Debug environment variable
		OS.get_environment("BEEKEEPER_DEBUG") == "1"  # Custom debug flag
	)
	
	if is_development_build:
		print("🛠️ Development build detected - debug overlay enabled")
	else:
		print("🚀 Production build detected - debug overlay disabled")

func create_debug_overlay():
	"""Create an in-game debug overlay to show keyboard events"""
	debug_label = Label.new()
	debug_label.position = Vector2(10, 10)
	debug_label.add_theme_font_size_override("font_size", 12)
	debug_label.add_theme_color_override("font_color", Color.YELLOW)
	debug_label.add_theme_color_override("font_outline_color", Color.BLACK)
	debug_label.add_theme_constant_override("outline_size", 2)
	debug_label.z_index = 1000  # On top of everything
	debug_label.text = "DEBUG: Press any key\n"
	add_child(debug_label)
	print("✅ Debug overlay created")

func add_debug_message(msg: String):
	"""Add a message to the debug overlay (only in development builds)"""
	if not is_development_build or not debug_label:
		return
	
	debug_messages.append(msg)
	if debug_messages.size() > MAX_DEBUG_MESSAGES:
		debug_messages.pop_front()
	
	if debug_label:
		debug_label.text = "\n".join(debug_messages)

func _input(event):
	# Debug: Log keyboard events in-game
	if event is InputEventKey and event.pressed and not event.is_echo():
		var key_name = OS.get_keycode_string(event.keycode)
		add_debug_message("KEY: %s (code: %d)" % [key_name, event.keycode])
		
		if event.keycode == KEY_F:
			add_debug_message("  -> F DETECTED!")
			add_debug_message("  -> HotkeyMgr: %d" % HotkeyManager.get_hotkey("speed_toggle"))
			var is_speed = HotkeyManager.is_hotkey_pressed(event, "speed_toggle")
			add_debug_message("  -> is_hotkey: %s" % is_speed)
			if is_speed:
				add_debug_message("  -> CALLING _on_speed_button_pressed()")
	
	# Handle mouse clicks for tower selection first
	if event is InputEventMouseButton and event.pressed:
		print("\n" + "=".repeat(80))
		print("🖱️ MOUSE INPUT EVENT")
		print("Button: %d, Position: %s" % [event.button_index, event.position])
		print("picked_up_tower: %s" % ("YES - " + metaprogression.picked_up_tower.tower_name if metaprogression.picked_up_tower else "NO"))
		print("is_in_tower_placement: %s" % is_in_tower_placement)
		print("=".repeat(80))

		if event.button_index == MOUSE_BUTTON_LEFT:
			# Check for metaprogression tower pickup first
			print("→ Calling handle_metaprogression_tower_pickup...")
			var handled = metaprogression.handle_metaprogression_tower_pickup(event.position)
			print("→ handle_metaprogression_tower_pickup returned: %s" % handled)
			if handled:
				print("✅ Event handled by metaprogression system\n")
				return
			# Then handle regular tower selection
			print("→ Calling handle_tower_click...")
			handle_tower_click(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Right click - clear selection
			clear_tower_selection()
		return  # Don't process other events for mouse clicks

	# Handle keyboard events
	if not event or not event is InputEventKey:
		return
	
	if not event.pressed or event.is_echo():
		return

	# Use dynamic hotkey system
	if HotkeyManager.is_hotkey_pressed(event, "place_stinger"):
		handle_tower_hotkey("stinger", "Stinger Tower")
	elif HotkeyManager.is_hotkey_pressed(event, "place_propolis_bomber"):
		handle_tower_hotkey("propolis_bomber", "Propolis Bomber Tower")
	elif HotkeyManager.is_hotkey_pressed(event, "place_nectar_sprayer"):
		handle_tower_hotkey("nectar_sprayer", "Nectar Sprayer Tower")
	elif HotkeyManager.is_hotkey_pressed(event, "place_lightning_flower"):
		handle_tower_hotkey("lightning_flower", "Lightning Flower Tower")
	elif HotkeyManager.is_hotkey_pressed(event, "place_tower"):
		# Toggle tower placement mode with current tower
		if is_in_tower_placement:
			tower_placer.cancel_placement()
		else:
			tower_placer.start_tower_placement(current_tower_type)
	elif HotkeyManager.is_hotkey_pressed(event, "start_wave"):
		# Start wave
		_on_start_wave_pressed()
	elif HotkeyManager.is_hotkey_pressed(event, "speed_toggle"):
		# Toggle speed
		_on_speed_button_pressed()


func handle_tower_click(click_position: Vector2):
	"""Handle left click to select towers and show range"""
	print("Tower click detected at position: ", click_position)

	# Don't select towers if we just placed one
	if is_placing_tower:
		print("Ignoring tower click - just placed a tower")
		return

	# Clear previous selection first
	clear_tower_selection()

	# Check if we clicked on a tower
	var tower = get_tower_at_position(click_position)
	if tower:
		print("Tower found: ", tower.tower_name)
		select_tower(tower)
	else:
		print("No tower found at click position")

func get_tower_at_position(position: Vector2) -> Tower:
	"""Get tower at the specified position"""
	if not tower_placer:
		print("No tower placer found")
		return null

	print("=== TOWER DETECTION ===")
	print("Checking ", tower_placer.placed_towers.size(), " towers for click at ", position)

	var closest_tower: Tower = null
	var closest_distance: float = 999999.0

	for i in range(tower_placer.placed_towers.size()):
		var tower = tower_placer.placed_towers[i]
		if tower and is_instance_valid(tower):
			var distance = tower.global_position.distance_to(position)
			print("Tower ", i, " (", tower.tower_name, ") at ", tower.global_position, " distance: ", distance)

			if distance <= 30:  # Within selection radius
				if distance < closest_distance:
					closest_distance = distance
					closest_tower = tower
					print("New closest tower: ", tower.tower_name, " at distance: ", distance)
		else:
			print("Tower ", i, " is invalid or null")

	if closest_tower:
		print("Selected closest tower: ", closest_tower.tower_name, " at distance: ", closest_distance)
	else:
		print("No tower found within selection radius")

	return closest_tower

func select_tower(tower: Tower):
	"""Select a tower and show its range"""
	if not tower or not is_instance_valid(tower):
		print("ERROR: Invalid tower passed to select_tower")
		return

	selected_tower = tower
	show_tower_range(tower)
	print("Selected tower: ", tower.tower_name)

func show_tower_range(tower: Tower):
	"""Show range indicator for the selected tower"""
	print("=== SHOWING TOWER RANGE ===")

	# Validate tower before proceeding
	if not tower or not is_instance_valid(tower):
		print("ERROR: Invalid tower in show_tower_range")
		return

	print("Tower: ", tower.tower_name, " at position: ", tower.global_position, " with range: ", tower.range)

	# Remove existing range indicator
	clear_range_indicator()

	# Wait one frame to ensure cleanup is complete
	await get_tree().process_frame

	# Double-check tower is still valid after frame wait
	if not tower or not is_instance_valid(tower):
		print("ERROR: Tower became invalid during range indicator creation")
		return

	print("Creating new range indicator for tower: ", tower.tower_name)

	# Create new range indicator
	range_indicator = Node2D.new()
	range_indicator.name = "RangeIndicator_" + str(tower.get_instance_id())

	# Create round range indicator using a custom drawing node
	var range_circle = create_round_range_indicator(tower.range)
	range_indicator.add_child(range_circle)

	# Position at tower location
	range_indicator.global_position = tower.global_position
	range_indicator.z_index = 5  # Ensure visibility

	# Add to scene
	var ui_canvas = $UI
	ui_canvas.add_child(range_indicator)

	print("Range indicator created: ", range_indicator.name, " at position: ", range_indicator.global_position, " with range: ", tower.range)
	print("=== RANGE INDICATOR SETUP COMPLETE ===")

func create_round_range_indicator(range: float) -> Node2D:
	"""Create a round range indicator using Line2D like in TowerPlacer"""
	var indicator = Node2D.new()
	indicator.name = "RoundRangeIndicator"

	# Create range circle using Line2D (same as TowerPlacer)
	var line = Line2D.new()
	line.width = 2.0
	line.default_color = Color(0.5, 0.5, 1.0, 0.5)  # Same color as TowerPlacer

	var points = []
	var segments = 32
	for i in range(segments + 1):
		var angle = i * 2 * PI / segments
		var point = Vector2(cos(angle), sin(angle)) * range
		points.append(point)

	line.points = PackedVector2Array(points)
	indicator.add_child(line)

	return indicator

func clear_tower_selection():
	"""Clear tower selection and hide range indicator"""
	selected_tower = null
	clear_range_indicator()

func clear_range_indicator():
	"""Remove range indicator from scene"""
	print("=== CLEARING RANGE INDICATOR ===")

	if range_indicator:
		print("Clearing current range indicator: ", range_indicator.name)
		if range_indicator.get_parent():
			range_indicator.get_parent().remove_child(range_indicator)
		range_indicator.queue_free()
		range_indicator = null
		print("Current range indicator cleared")

	# Additional cleanup: remove any remaining range indicators from UI
	var ui_canvas = $UI
	if ui_canvas:
		var children_to_remove = []
		for child in ui_canvas.get_children():
			if child.name.begins_with("RangeIndicator"):
				print("Found leftover range indicator: ", child.name)
				children_to_remove.append(child)

		for child in children_to_remove:
			print("Removing leftover range indicator: ", child.name)
			ui_canvas.remove_child(child)
			child.queue_free()

		if children_to_remove.size() > 0:
			print("Removed ", children_to_remove.size(), " leftover range indicators")
		else:
			print("No leftover range indicators found")
	else:
		print("No UI canvas found for cleanup")

	print("=== RANGE INDICATOR CLEANUP COMPLETE ===")

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
		# Legacy support
		"basic_shooter":
			return 25
		"piercing_shooter":
			return 35
		_:
			return 25

func _on_tower_placed(tower: Tower, position: Vector2):
	print("Tower placed successfully: " + tower.tower_name)
	is_placing_tower = true
	update_ui()

	# Clear the placement flag after a short delay to prevent immediate selection
	var timer = get_tree().create_timer(0.1)
	timer.timeout.connect(_on_tower_placement_complete)

func _on_tower_placement_failed(reason: String):
	print("Tower placement failed: " + reason)

func _on_placement_mode_changed(is_active: bool):
	if place_tower_button:
		place_tower_button.button_pressed = is_active
	is_in_tower_placement = is_active

	# Reset placement flag when exiting placement mode
	if not is_active:
		is_placing_tower = false
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_tower_placement_complete():
	"""Called after tower placement is complete to allow selection again"""
	is_placing_tower = false
	print("Tower placement complete, selection enabled again")

func reset_game_state():
	"""Reset all game state to initial values for a new game"""
	print("Resetting game state for new game")

	# Reset player stats
	player_health = 20
	current_wave = 0  # 0 = no wave started yet, will show "Next: Wave 1"

	# Reset GameManager resources
	GameManager.set_resource("honey", 100)

	# Reset speed mode
	if speed_mode != 0:
		speed_mode = 0
		Engine.time_scale = 1.0
		if speed_button:
			ui_manager.update_speed_button_text()

	print("Game state reset complete")

func setup_cursor_timer():
	cursor_timer = Timer.new()
	cursor_timer.wait_time = 0.3
	cursor_timer.one_shot = true
	cursor_timer.timeout.connect(_on_cursor_timer_timeout)
	add_child(cursor_timer)

func _on_start_wave_button_mouse_entered():
	if is_in_tower_placement:
		is_hovering_ui = true
		cursor_timer.start()

func _on_start_wave_button_mouse_exited():
	if is_in_tower_placement:
		is_hovering_ui = false
		cursor_timer.stop()
		# Restore cursor immediately when leaving UI
		Input.set_default_cursor_shape(Input.CURSOR_CROSS)

func _on_cursor_timer_timeout():
	if is_hovering_ui and is_in_tower_placement:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_speed_button_pressed():
	# Cycle through speed modes: 0 -> 1 -> 2 -> 0
	var old_mode = speed_mode
	speed_mode = (speed_mode + 1) % 3
	add_debug_message("Speed: %d -> %d" % [old_mode, speed_mode])
	apply_speed_mode()
	add_debug_message("time_scale: %.1f" % Engine.time_scale)
	
	# CRITICAL: Check if button still exists
	if ui_manager and ui_manager.speed_button:
		add_debug_message("✅ speed_button EXISTS when F pressed")
	elif ui_manager:
		add_debug_message("❌ speed_button is NULL when F pressed!")
	
	# Update button text
	add_debug_message("Calling update_speed_button_text()...")
	if ui_manager:
		ui_manager.update_speed_button_text()
	else:
		add_debug_message("ERROR: ui_manager is null!")

func apply_speed_mode():
	match speed_mode:
		0:  # Normal speed
			Engine.time_scale = 1.0
			print("Speed mode: Normal (1x)")
		1:  # Double speed
			Engine.time_scale = 2.0
			print("Speed mode: Double (2x)")
		2:  # Triple speed
			Engine.time_scale = 3.0
			print("Speed mode: Triple (3x)")

func _on_hotkey_changed(action: String, old_key: int, new_key: int):
	"""Update button texts when hotkeys change"""
	print("Hotkey changed for ", action, " - updating button texts")
	ui_manager.update_button_texts()

func _on_resources_changed(resource_type: String, amount: int):
	"""Handle resource changes to update UI immediately"""
	if resource_type == "honey":
		update_ui()
		print("Honey changed by: %d (Total: %d)" % [amount, GameManager.get_resource("honey")])

func _on_tree_exiting():
	"""
	Called when scene is about to be removed from tree
	Auto-save before leaving
	"""
	print("👋 Exiting Tower Defense, auto-saving...")
	save_system.auto_save_game("Exiting Tower Defense")

func _on_wave_countdown_timer_timeout():
	"""Delegate to wave controller"""
	wave_controller._on_wave_countdown_timer_timeout()

func handle_tower_hotkey(tower_type: String, tower_name: String):
	"""Handle tower placement hotkeys"""
	print("\n=== TOWER HOTKEY PRESSED ===")
	print("Tower Type: ", tower_type)
	print("Tower Name: ", tower_name)

	# Check if player has enough honey
	var tower_cost = get_tower_cost(tower_type)
	var current_honey = GameManager.get_resource("honey")

	if current_honey < tower_cost:
		print("❌ Not enough honey! Need: ", tower_cost, ", Have: ", current_honey)
		ui_manager.show_insufficient_honey_dialog(tower_cost, current_honey)
		return

	# Set current tower type and start placement
	current_tower_type = tower_type
	ui_manager.update_button_selection()

	# Start tower placement with TowerPlacer
	print("Starting tower placement...")
	tower_placer.start_tower_placement(current_tower_type)

func show_victory_screen():
	"""Delegate to UI manager"""
	ui_manager.show_victory_screen()

func start_tower_following_mouse():
	"""Start tower following mouse for metaprogression system"""
	# This is used by the metaprogression system
	pass

func stop_tower_following_mouse():
	"""Stop tower following mouse for metaprogression system"""
	# This is used by the metaprogression system
	pass

func show_tower_range_at_mouse_position(tower: Tower):
	"""Show tower range at mouse position for metaprogression preview"""
	# Remove existing range indicator
	clear_range_indicator()

	# Create new range indicator
	range_indicator = Node2D.new()
	range_indicator.name = "RangeIndicator_Mouse"

	# Create round range indicator
	var range_circle = create_round_range_indicator(tower.range)
	range_indicator.add_child(range_circle)

	# Position at mouse
	range_indicator.z_index = 5

	# Add to scene
	var ui_canvas = $UI
	ui_canvas.add_child(range_indicator)

func _process(delta):
	"""Update mouse-following range indicator"""
	if metaprogression.picked_up_tower and range_indicator:
		range_indicator.global_position = get_global_mouse_position()
		metaprogression.picked_up_tower.global_position = get_global_mouse_position()

# =============================================================================
# INTEGRATION TEST FOR LIGHTNING FLOWER PLACEMENT & SELECTION
# =============================================================================

func run_lightning_flower_integration_test():
	"""Run integration test for Lightning Flower placement and selection"""
	print("\n" + "=".repeat(60))
	print("🧪 RUNNING LIGHTNING FLOWER INTEGRATION TEST")
	print("=".repeat(60))

	await get_tree().process_frame  # Wait for scene to stabilize

	# Test 1: Place Lightning Flower
	print("Test 1: Placing Lightning Flower...")
	var placement_success = await test_lightning_flower_placement()

	if not placement_success:
		print("❌ PLACEMENT FAILED - Aborting further tests")
		return

	# Test 2: Select Lightning Flower
	print("Test 2: Selecting Lightning Flower...")
	var selection_success = await test_lightning_flower_selection()

	# Test 3: Range Indicator
	print("Test 3: Testing Range Indicator...")
	var range_success = test_lightning_flower_range_indicator()

	# Final report
	print("\n" + "=".repeat(60))
	if placement_success and selection_success and range_success:
		print("✅ ALL LIGHTNING FLOWER TESTS PASSED")
	else:
		print("❌ SOME LIGHTNING FLOWER TESTS FAILED")
		print("Placement: %s, Selection: %s, Range: %s" % [
			"✅" if placement_success else "❌",
			"✅" if selection_success else "❌",
			"✅" if range_success else "❌"
		])
	print("=".repeat(60))

func test_lightning_flower_placement() -> bool:
	"""Test Lightning Flower placement"""
	# Ensure we have enough honey
	GameManager.set_resource("honey", 100)

	# Clear any existing placement mode
	if tower_placer and tower_placer.current_mode != TowerPlacer.PlacementMode.NONE:
		tower_placer.cancel_placement()

	# Start Lightning Flower placement
	_on_place_tower_pressed("lightning_flower")

	await get_tree().process_frame

	# Place at a safe position
	var safe_position = Vector2(300, 300)
	if tower_placer:
		tower_placer.place_tower(safe_position)
		await get_tree().process_frame

		# Check if tower was placed
		if tower_placer.placed_towers.size() > 0:
			var last_tower = tower_placer.placed_towers[-1]
			if last_tower and last_tower.tower_name == "Lightning Flower":
				print("✅ Lightning Flower placed successfully at: ", safe_position)
				return true
			else:
				print("❌ FAILED: Wrong tower type placed")
		else:
			print("❌ FAILED: No tower was placed")
	else:
		print("❌ FAILED: No tower placer")

	return false

func test_lightning_flower_selection() -> bool:
	"""Test Lightning Flower selection"""
	if tower_placer.placed_towers.size() == 0:
		print("❌ FAILED: No towers to select")
		return false

	var tower = tower_placer.placed_towers[-1]
	if tower and tower.tower_name == "Lightning Flower":
		# Simulate tower selection
		select_tower(tower)
		await get_tree().process_frame

		if selected_tower == tower:
			print("✅ Lightning Flower selected successfully")
			return true
		else:
			print("❌ FAILED: Tower not selected")
	else:
		print("❌ FAILED: No Lightning Flower found")

	return false

func test_lightning_flower_range_indicator() -> bool:
	"""Test range indicator display"""
	if not range_indicator:
		print("❌ FAILED: No range indicator found")
		return false

	if range_indicator.get_parent():
		print("✅ Range indicator is in scene tree")
		return true
	else:
		print("❌ FAILED: Range indicator not in scene tree")
		return false