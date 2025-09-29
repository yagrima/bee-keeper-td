extends Node2D

@onready var map = $Map
@onready var path_layer = $Map/PathLayer
@onready var build_layer = $Map/BuildLayer
@onready var camera = $Camera2D

@onready var honey_label = $UI/GameUI/TopBar/ResourceDisplay/HoneyLabel
@onready var health_label = $UI/GameUI/TopBar/ResourceDisplay/HealthLabel
@onready var wave_label = $UI/GameUI/TopBar/ResourceDisplay/WaveLabel
@onready var wave_composition_label: Label
@onready var wave_countdown_label: Label
@onready var start_wave_button = $UI/GameUI/Controls/StartWaveButton
@onready var place_tower_button = $UI/GameUI/Controls/PlaceTowerButton
@onready var back_button = $UI/GameUI/Controls/BackButton
@onready var speed_button: Button

var current_wave: int = 1
var player_health: int = 20
var honey: int = 100
var speed_mode: int = 0  # 0 = normal, 1 = 2x, 2 = 3x

# Tower placement
var tower_placer: TowerPlacer
var current_tower_type: String = "stinger"
var available_tower_types: Array[String] = ["stinger", "propolis_bomber", "nectar_sprayer", "lightning_flower"]

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

# Metaprogression system
var metaprogression_towers: Array[Tower] = []  # Towers in metaprogression fields
var picked_up_tower: Tower = null  # Currently picked up tower

func _ready():
	GameManager.change_game_state(GameManager.GameState.TOWER_DEFENSE)

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
	update_button_texts()

	# Connect to hotkey changes to update button texts
	HotkeyManager.hotkey_changed.connect(_on_hotkey_changed)
	
	# Connect to GameManager signals for real-time UI updates
	GameManager.resources_changed.connect(_on_resources_changed)

	# Connect mouse hover signals for cursor management
	if start_wave_button:
		start_wave_button.mouse_entered.connect(_on_start_wave_button_mouse_entered)
		start_wave_button.mouse_exited.connect(_on_start_wave_button_mouse_exited)

	setup_basic_map()
	setup_tower_placer()
	setup_wave_manager()
	setup_cursor_timer()
	setup_wave_composition_ui()
	setup_wave_countdown_ui()
	setup_individual_tower_buttons()
	setup_speed_button()
	setup_metaprogression_fields()
	update_ui()

	# Check for pending save data to load
	check_for_pending_save_data()

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

		// Determine line width - make specific problematic lines thicker
		float current_line_width = line_width;

		// Check if we're near the problematic vertical line at x=160 (5th field boundary)
		float distance_to_160 = abs(pixel_pos.x - 160.0);
		if (distance_to_160 < 1.0) {
			current_line_width = 0.55;  // Make this line barely thicker
		}

		// Simple check: if we're within current_line_width pixels of a grid boundary
		bool on_vertical_line = grid_check.x < current_line_width || grid_check.x > (grid_size - current_line_width);
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
	shader_material.set_shader_parameter("line_width", 0.5)

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

	# Connect signals
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.enemy_spawned.connect(_on_enemy_spawned)
	wave_manager.all_waves_completed.connect(_on_all_waves_completed)

func _on_start_wave_pressed():
	if wave_manager.is_wave_in_progress():
		print("Wave already in progress!")
		return

	# Clear tower selection when starting wave
	clear_tower_selection()
	
	# Stop any existing auto wave timer and countdown
	stop_auto_wave_timer()

	wave_manager.start_wave(current_wave)
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
		show_insufficient_honey_dialog(tower_cost, current_honey)
		return

	# Set current tower type and start placement
	current_tower_type = selected_type
	update_button_selection()
	tower_placer.start_tower_placement(current_tower_type)

# Removed old tower type cycle functions - now using individual buttons

func _on_back_pressed():
	SceneManager.goto_main_menu()

func update_ui():
	honey_label.text = "Honey: " + str(GameManager.get_resource("honey"))
	health_label.text = "Health: " + str(player_health)
	wave_label.text = "Wave: " + str(current_wave)

	# Update wave composition display
	if wave_composition_label and wave_manager:
		var composition = wave_manager.get_wave_composition(current_wave)
		var scaling_info = wave_manager.get_wave_scaling_info()
		if composition != "":
			wave_composition_label.text = "Wave " + str(current_wave) + ": " + composition + " (" + scaling_info + ")"
		else:
			wave_composition_label.text = ""

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
	show_game_over_screen()

func setup_tower_placer():
	tower_placer = TowerPlacer.new()
	add_child(tower_placer)

	# Connect signals
	tower_placer.tower_placed.connect(_on_tower_placed)
	tower_placer.tower_placement_failed.connect(_on_tower_placement_failed)
	tower_placer.placement_mode_changed.connect(_on_placement_mode_changed)

func _input(event):
	# Handle mouse clicks for tower selection first
	if event is InputEventMouseButton and event.pressed:
		print("Mouse button pressed: ", event.button_index, " at position: ", event.position)
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Check for metaprogression tower pickup first
			if handle_metaprogression_tower_pickup(event.position):
				return
			# Then handle regular tower selection
			handle_tower_click(event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			# Right click - clear selection
			clear_tower_selection()
		return  # Don't process other events for mouse clicks
	
	# Handle keyboard events
	if not event or not event is InputEventKey or not event.pressed:
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
	elif event.keycode == KEY_T and event.pressed:
		# Test tower positioning system
		test_tower_positioning()
	elif HotkeyManager.is_hotkey_pressed(event, "save_game"):
		# Save game
		_on_save_game_pressed()
	elif HotkeyManager.is_hotkey_pressed(event, "load_game"):
		# Load game
		_on_load_game_pressed()
	elif HotkeyManager.is_hotkey_pressed(event, "quick_save"):
		# Quick save
		_on_quick_save_pressed()
	elif HotkeyManager.is_hotkey_pressed(event, "quick_load"):
		# Quick load
		_on_quick_load_pressed()
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

func show_insufficient_honey_dialog(required_honey: int, current_honey: int):
	"""Show dialog when player doesn't have enough honey"""
	var dialog = AcceptDialog.new()
	dialog.title = "Insufficient Honey"
	dialog.dialog_text = "You need " + str(required_honey) + " honey to build this tower.\nYou currently have " + str(current_honey) + " honey."
	dialog.size = Vector2(300, 150)
	
	# Add to scene
	var ui_canvas = $UI
	ui_canvas.add_child(dialog)
	
	# Center the dialog
	var window_size = Vector2(get_viewport().get_visible_rect().size)
	dialog.position = (window_size - Vector2(dialog.size)) / 2
	
	# Auto-close after 3 seconds
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(dialog.queue_free)

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

func _on_wave_started(wave_number: int):
	print("Wave ", wave_number, " started!")
	update_ui()  # Update UI to show current wave composition
	
	# Start a timer to update wave composition in real-time
	start_wave_composition_timer()

func _on_wave_completed(wave_number: int, enemies_killed: int):
	print("Wave ", wave_number, " completed! Killed ", enemies_killed, " enemies")
	current_wave += 1
	
	# Check if all waves are completed
	if current_wave > 5:
		_on_all_waves_completed()
		return
	
	# Stop the wave composition timer
	stop_wave_composition_timer()
	
	# Start automatic next wave after delay based on speed mode
	start_automatic_next_wave()
	
	update_ui()  # Update UI for next wave

func _on_enemy_spawned(enemy: Enemy):
	print("Enemy spawned: ", enemy.enemy_name)

func _on_all_waves_completed():
	print("All waves completed! Victory!")
	
	# Stop the wave composition timer
	stop_wave_composition_timer()
	
	# Stop any auto wave timer
	stop_auto_wave_timer()
	
	# Delay victory screen by 0.01 seconds to allow last enemy to despawn
	var timer = get_tree().create_timer(0.01)
	timer.timeout.connect(show_victory_screen)

func show_victory_screen():
	# Create victory overlay
	var victory_overlay = ColorRect.new()
	victory_overlay.name = "VictoryOverlay"
	victory_overlay.color = Color(0, 0, 0, 0.7)  # Semi-transparent black
	victory_overlay.size = Vector2(get_viewport().get_visible_rect().size)
	victory_overlay.position = Vector2.ZERO
	victory_overlay.z_index = 100  # Ensure it's on top

	# Create victory panel
	var victory_panel = Panel.new()
	victory_panel.name = "VictoryPanel"
	var panel_size = Vector2(400, 300)
	var window_size = Vector2(get_viewport().get_visible_rect().size)
	victory_panel.size = panel_size
	victory_panel.position = (window_size - panel_size) / 2  # Center the panel

	# Style the panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.2, 0.4, 0.2)  # Dark green
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color.GOLD
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	victory_panel.add_theme_stylebox_override("panel", panel_style)

	# Victory title
	var title_label = Label.new()
	title_label.text = "🏆 VICTORY! 🏆"
	title_label.position = Vector2(0, 30)
	title_label.size = Vector2(panel_size.x, 50)
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	victory_panel.add_child(title_label)

	# Victory message
	var message_label = Label.new()
	message_label.text = "All waves successfully defended!\nThe hive is safe!"
	message_label.position = Vector2(0, 80)
	message_label.size = Vector2(panel_size.x, 60)
	message_label.add_theme_font_size_override("font_size", 18)
	message_label.add_theme_color_override("font_color", Color.WHITE)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	victory_panel.add_child(message_label)

	# Statistics
	var stats_label = Label.new()
	var final_honey = GameManager.get_resource("honey")
	stats_label.text = "Verbleibendes Leben:\nHealth: " + str(player_health) + "/20\nWaves Completed: 5/5"
	stats_label.position = Vector2(0, 140)
	stats_label.size = Vector2(panel_size.x, 60)
	stats_label.add_theme_font_size_override("font_size", 16)
	stats_label.add_theme_color_override("font_color", Color.WHITE)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	victory_panel.add_child(stats_label)

	# Return to menu button
	var menu_button = Button.new()
	menu_button.text = "Return to Main Menu"
	menu_button.size = Vector2(200, 40)
	menu_button.position = Vector2(panel_size.x / 2 - 100, 250)
	
	# Connect the button signal with error handling
	if not menu_button.pressed.is_connected(_on_victory_menu_button_pressed):
		menu_button.pressed.connect(_on_victory_menu_button_pressed)
		print("Victory menu button connected successfully")
	else:
		print("Victory menu button already connected")
	
	# Connect alternative handler as backup
	if not menu_button.pressed.is_connected(_on_victory_button_clicked):
		menu_button.pressed.connect(_on_victory_button_clicked)
		print("Victory button alternative handler connected")
	
	# Alternative: Use call_deferred to ensure the connection works
	call_deferred("_connect_victory_button", menu_button)
	
	victory_panel.add_child(menu_button)

	# Add to scene
	victory_overlay.add_child(victory_panel)
	var ui_canvas = $UI
	ui_canvas.add_child(victory_overlay)

	# Disable game controls
	start_wave_button.disabled = true
	place_tower_button.disabled = true

	# Don't pause the game - this prevents UI from working
	# get_tree().paused = true

func _on_victory_menu_button_pressed():
	print("Victory menu button pressed - returning to main menu")
	
	# Clean up victory screen
	cleanup_victory_screen()
	
	# Return to main menu
	SceneManager.goto_main_menu()

func _on_victory_button_clicked():
	# Alternative button handler
	print("Victory button clicked - alternative handler")
	_on_victory_menu_button_pressed()

func cleanup_victory_screen():
	# Remove victory overlay if it exists
	var victory_overlay = $UI.get_node_or_null("VictoryOverlay")
	if victory_overlay:
		victory_overlay.queue_free()
		print("Victory overlay cleaned up")

func _connect_victory_button(button: Button):
	# Ensure the button is properly connected
	if button and not button.pressed.is_connected(_on_victory_menu_button_pressed):
		button.pressed.connect(_on_victory_menu_button_pressed)
		print("Victory button connected via deferred call")

func show_game_over_screen():
	# Create game over overlay
	var game_over_overlay = ColorRect.new()
	game_over_overlay.name = "GameOverOverlay"
	game_over_overlay.color = Color(0, 0, 0, 0.8)  # Semi-transparent black
	game_over_overlay.size = Vector2(get_viewport().get_visible_rect().size)
	game_over_overlay.position = Vector2.ZERO
	game_over_overlay.z_index = 100  # Ensure it's on top

	# Create game over panel
	var game_over_panel = Panel.new()
	game_over_panel.name = "GameOverPanel"
	var panel_size = Vector2(400, 300)
	var window_size = Vector2(get_viewport().get_visible_rect().size)
	game_over_panel.size = panel_size
	game_over_panel.position = (window_size - panel_size) / 2  # Center the panel

	# Style the panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.4, 0.2, 0.2)  # Dark red
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color.RED
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	game_over_panel.add_theme_stylebox_override("panel", panel_style)

	# Game over title
	var title_label = Label.new()
	title_label.text = "💀 GAME OVER 💀"
	title_label.position = Vector2(0, 30)
	title_label.size = Vector2(panel_size.x, 50)
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_over_panel.add_child(title_label)

	# Game over message
	var message_label = Label.new()
	message_label.text = "The hive has been overrun!\nYour defenses have failed!"
	message_label.position = Vector2(0, 80)
	message_label.size = Vector2(panel_size.x, 60)
	message_label.add_theme_font_size_override("font_size", 18)
	message_label.add_theme_color_override("font_color", Color.WHITE)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_over_panel.add_child(message_label)

	# Statistics
	var stats_label = Label.new()
	var final_honey = GameManager.get_resource("honey")
	stats_label.text = "Final Score:\nHoney Collected: " + str(final_honey) + "\nWaves Survived: " + str(current_wave - 1) + "/5"
	stats_label.position = Vector2(0, 140)
	stats_label.size = Vector2(panel_size.x, 60)
	stats_label.add_theme_font_size_override("font_size", 16)
	stats_label.add_theme_color_override("font_color", Color.WHITE)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_over_panel.add_child(stats_label)

	# Return to menu button
	var menu_button = Button.new()
	menu_button.text = "Return to Main Menu"
	menu_button.size = Vector2(200, 40)
	menu_button.position = Vector2(panel_size.x / 2 - 100, 250)
	menu_button.pressed.connect(_on_game_over_menu_button_pressed)
	game_over_panel.add_child(menu_button)

	# Add to scene
	game_over_overlay.add_child(game_over_panel)
	var ui_canvas = $UI
	ui_canvas.add_child(game_over_overlay)

	# Disable game controls
	start_wave_button.disabled = true
	place_tower_button.disabled = true

	# Don't pause the game - this prevents UI from working
	# get_tree().paused = true

func _on_game_over_menu_button_pressed():
	print("Game over menu button pressed - returning to main menu")
	
	# Clean up game over screen
	cleanup_game_over_screen()
	
	# Return to main menu
	SceneManager.goto_main_menu()

func reset_game_state():
	"""Reset all game state to initial values for a new game"""
	print("Resetting game state for new game")
	
	# Reset player stats
	player_health = 20
	current_wave = 1
	
	# Reset GameManager resources
	GameManager.set_resource("honey", 100)
	
	# Reset speed mode
	if speed_mode != 0:
		speed_mode = 0
		Engine.time_scale = 1.0
		update_speed_button_text()
	
	print("Game state reset complete")

func cleanup_game_over_screen():
	# Remove game over overlay if it exists
	var game_over_overlay = $UI.get_node_or_null("GameOverOverlay")
	if game_over_overlay:
		game_over_overlay.queue_free()
		print("Game over overlay cleaned up")


func setup_cursor_timer():
	cursor_timer = Timer.new()
	cursor_timer.wait_time = 0.3
	cursor_timer.one_shot = true
	cursor_timer.timeout.connect(_on_cursor_timer_timeout)
	add_child(cursor_timer)

func setup_wave_composition_ui():
	# Create wave composition label and position it to avoid overlap
	wave_composition_label = Label.new()
	wave_composition_label.name = "WaveCompositionLabel"

	# Position it below the resource display area with proper spacing
	wave_composition_label.position = Vector2(20, 70)  # Positioned below resource display
	wave_composition_label.add_theme_font_size_override("font_size", 13)  # Smaller font for better fit
	wave_composition_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))  # Slightly lighter
	wave_composition_label.text = ""
	wave_composition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	wave_composition_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	# Add to UI layer
	var ui_canvas = $UI
	ui_canvas.add_child(wave_composition_label)

func setup_wave_countdown_ui():
	"""Setup wave countdown timer display"""
	# Create wave countdown label
	wave_countdown_label = Label.new()
	wave_countdown_label.name = "WaveCountdownLabel"
	
	# Position it below the wave composition label
	wave_countdown_label.position = Vector2(20, 90)  # Below wave composition
	wave_countdown_label.add_theme_font_size_override("font_size", 12)
	wave_countdown_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))  # Same color as other labels
	wave_countdown_label.text = ""
	wave_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	wave_countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	
	# Add to UI layer
	var ui_canvas = $UI
	ui_canvas.add_child(wave_countdown_label)
	
	# Create countdown timer
	wave_countdown_timer = Timer.new()
	wave_countdown_timer.name = "WaveCountdownTimer"
	wave_countdown_timer.wait_time = 1.0  # Update every second
	wave_countdown_timer.timeout.connect(_on_wave_countdown_timer_timeout)
	add_child(wave_countdown_timer)

func setup_individual_tower_buttons():
	# Create four individual tower buttons
	var button_parent = place_tower_button.get_parent()
	var base_position = place_tower_button.position
	var button_size = Vector2(130, 40)
	var button_spacing = 140

	# Stinger Tower Button
	stinger_button = Button.new()
	stinger_button.name = "StingerButton"
	stinger_button.text = "Q: Stinger (20)"
	stinger_button.size = button_size
	stinger_button.position = Vector2(base_position.x + button_spacing * 0, base_position.y)
	stinger_button.pressed.connect(func(): _on_place_tower_pressed("stinger"))
	button_parent.add_child(stinger_button)

	# Propolis Bomber Button
	propolis_bomber_button = Button.new()
	propolis_bomber_button.name = "PropolisBomberButton"
	propolis_bomber_button.text = "W: Propolis (45)"
	propolis_bomber_button.size = button_size
	propolis_bomber_button.position = Vector2(base_position.x + button_spacing * 1, base_position.y)
	propolis_bomber_button.pressed.connect(func(): _on_place_tower_pressed("propolis_bomber"))
	button_parent.add_child(propolis_bomber_button)

	# Nectar Sprayer Button
	nectar_sprayer_button = Button.new()
	nectar_sprayer_button.name = "NectarSprayerButton"
	nectar_sprayer_button.text = "E: Nectar (30)"
	nectar_sprayer_button.size = button_size
	nectar_sprayer_button.position = Vector2(base_position.x + button_spacing * 2, base_position.y)
	nectar_sprayer_button.pressed.connect(func(): _on_place_tower_pressed("nectar_sprayer"))
	button_parent.add_child(nectar_sprayer_button)

	# Lightning Flower Button
	lightning_flower_button = Button.new()
	lightning_flower_button.name = "LightningFlowerButton"
	lightning_flower_button.text = "R: Lightning (35)"
	lightning_flower_button.size = button_size
	lightning_flower_button.position = Vector2(base_position.x + button_spacing * 3, base_position.y)
	lightning_flower_button.pressed.connect(func(): _on_place_tower_pressed("lightning_flower"))
	button_parent.add_child(lightning_flower_button)

	# Hide the old place tower button
	if place_tower_button:
		place_tower_button.visible = false

	# Update selection to show current tower
	update_button_selection()

func update_button_selection():
	"""Update button visual state to show current selection"""
	# Reset all buttons
	if stinger_button:
		stinger_button.button_pressed = false
	if propolis_bomber_button:
		propolis_bomber_button.button_pressed = false
	if nectar_sprayer_button:
		nectar_sprayer_button.button_pressed = false
	if lightning_flower_button:
		lightning_flower_button.button_pressed = false

	# Highlight current selection
	match current_tower_type:
		"stinger":
			if stinger_button:
				stinger_button.button_pressed = true
		"propolis_bomber":
			if propolis_bomber_button:
				propolis_bomber_button.button_pressed = true
		"nectar_sprayer":
			if nectar_sprayer_button:
				nectar_sprayer_button.button_pressed = true
		"lightning_flower":
			if lightning_flower_button:
				lightning_flower_button.button_pressed = true

func setup_speed_button():
	# Create speed button next to the tower buttons
	speed_button = Button.new()
	speed_button.name = "SpeedButton"
	speed_button.size = Vector2(150, 40)

	# Position it next to the lightning flower button
	var lightning_pos = lightning_flower_button.position
	speed_button.position = Vector2(lightning_pos.x + 150, lightning_pos.y)

	# Connect signal
	if speed_button:
		speed_button.pressed.connect(_on_speed_button_pressed)

	# Add to same parent as tower buttons
	lightning_flower_button.get_parent().add_child(speed_button)

	# Initialize button text
	update_speed_button_text()

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
	speed_mode = (speed_mode + 1) % 3
	apply_speed_mode()
	update_speed_button_text()

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

func update_speed_button_text():
	if speed_button:
		match speed_mode:
			0:
				speed_button.text = HotkeyManager.get_action_display_text("speed_toggle") + " (1x)"
			1:
				speed_button.text = HotkeyManager.get_action_display_text("speed_toggle") + " (2x)"
			2:
				speed_button.text = HotkeyManager.get_action_display_text("speed_toggle") + " (3x)"

func update_button_texts():
	"""Update button texts with current hotkey assignments"""
	if start_wave_button:
		start_wave_button.text = HotkeyManager.get_action_display_text("start_wave")
	if place_tower_button:
		place_tower_button.text = HotkeyManager.get_action_display_text("place_tower")

func _on_hotkey_changed(action: String, old_key: int, new_key: int):
	"""Update button texts when hotkeys change"""
	print("Hotkey changed for ", action, " - updating button texts")
	update_button_texts()

func _on_resources_changed(resource_type: String, amount: int):
	"""Handle resource changes to update UI immediately"""
	if resource_type == "honey":
		update_ui()
		print("Honey changed by: %d (Total: %d)" % [amount, GameManager.get_resource("honey")])

func get_tower_defense_data() -> Dictionary:
	"""Get current tower defense scene data for saving"""
	var tower_data = []
	
	# Get tower data from tower placer
	if tower_placer:
		var placed_towers = tower_placer.get_placed_towers()
		for tower in placed_towers:
			if tower and is_instance_valid(tower):
				tower_data.append({
					"type": tower.tower_name,
					"position": {
						"x": tower.global_position.x,
						"y": tower.global_position.y
					},
					"level": tower.level,
					"damage": tower.damage,
					"range": tower.range,
					"attack_speed": tower.attack_speed,
					"honey_cost": tower.honey_cost,
					"upgrade_cost": tower.get_upgrade_cost()
				})
	
	# Get wave data
	var wave_data = {}
	if wave_manager:
		wave_data = {
			"current_wave": wave_manager.get_current_wave(),
			"is_wave_active": wave_manager.is_wave_in_progress(),
			"wave_progress": wave_manager.get_wave_progress()
		}
	
	return {
		"current_wave": current_wave,
		"player_health": player_health,
		"honey": GameManager.get_resource("honey"),
		"placed_towers": tower_data,
		"wave_data": wave_data,
		"current_tower_type": current_tower_type
	}

func load_tower_defense_data(data: Dictionary):
	"""Load tower defense scene data from save"""
	if data.has("current_wave"):
		current_wave = data["current_wave"]
	if data.has("player_health"):
		player_health = data["player_health"]
	if data.has("honey"):
		# Set honey resource
		var current_honey = GameManager.get_resource("honey")
		var honey_diff = data["honey"] - current_honey
		if honey_diff != 0:
			GameManager.add_resource("honey", honey_diff)
	if data.has("current_tower_type"):
		current_tower_type = data["current_tower_type"]
	
	# Load towers
	if data.has("placed_towers") and tower_placer:
		load_placed_towers(data["placed_towers"])
	
	# Load wave data
	if data.has("wave_data") and wave_manager:
		load_wave_data(data["wave_data"])
	
	# Update UI
	update_ui()

func load_placed_towers(tower_data: Array):
	"""Load placed towers from save data"""
	# Clear existing towers
	if tower_placer:
		var existing_towers = tower_placer.get_placed_towers()
		for tower in existing_towers:
			if tower and is_instance_valid(tower):
				tower.queue_free()
		tower_placer.placed_towers.clear()
	
	# Place saved towers
	for tower_info in tower_data:
		place_tower_from_save(tower_info)

func place_tower_from_save(tower_info: Dictionary):
	"""Place a tower from save data"""
	var tower_type = tower_info.get("type", "basic_shooter")
	var position = Vector2(tower_info.get("position", {}).get("x", 0), tower_info.get("position", {}).get("y", 0))
	
	# Create tower instance
	var tower_script = null
	match tower_type:
		"stinger":
			tower_script = load("res://scripts/StingerTower.gd")
		"propolis_bomber":
			tower_script = load("res://scripts/PropolisBomberTower.gd")
		"nectar_sprayer":
			tower_script = load("res://scripts/NectarSprayerTower.gd")
		"lightning_flower":
			tower_script = load("res://scripts/LightningFlowerTower.gd")
		_:
			print("Unknown tower type in save: ", tower_type)
			return
	
	if tower_script:
		var tower = tower_script.new() as Tower
		
		# Set tower properties
		if tower_info.has("level"):
			tower.level = tower_info["level"]
		if tower_info.has("damage"):
			tower.damage = tower_info["damage"]
		if tower_info.has("range"):
			tower.range = tower_info["range"]
		if tower_info.has("attack_speed"):
			tower.attack_speed = tower_info["attack_speed"]
		if tower_info.has("honey_cost"):
			tower.honey_cost = tower_info["honey_cost"]
		if tower_info.has("upgrade_cost"):
			tower.upgrade_cost = tower_info["upgrade_cost"]
		
		# Position tower
		tower.global_position = position
		
		# Add to scene
		var ui_canvas = $UI
		ui_canvas.add_child(tower)
		
		# Add to tower placer
		if tower_placer:
			tower_placer.placed_towers.append(tower)
			tower.tower_destroyed.connect(tower_placer._on_tower_destroyed)
		
		print("Loaded tower: ", tower_type, " at ", position)

func load_wave_data(wave_data: Dictionary):
	"""Load wave data from save"""
	if wave_manager and wave_data.has("current_wave"):
		# Set wave number but don't start the wave
		current_wave = wave_data["current_wave"]
		# Note: We don't restore active waves to avoid complications
		print("Loaded wave data: Wave ", current_wave)

func _on_save_game_pressed():
	"""Handle save game hotkey"""
	show_save_dialog()

func _on_load_game_pressed():
	"""Handle load game hotkey"""
	show_load_dialog()

func _on_quick_save_pressed():
	"""Handle quick save hotkey"""
	quick_save()

func _on_quick_load_pressed():
	"""Handle quick load hotkey"""
	quick_load()

func quick_save():
	"""Quick save to a default slot"""
	var success = GameManager.save_game("quick_save")
	if success:
		show_save_notification("Quick Save", "Game saved successfully!")
	else:
		show_save_notification("Quick Save", "Failed to save game!")

func quick_load():
	"""Quick load from default slot"""
	if GameManager.save_file_exists("quick_save"):
		var success = GameManager.load_game("quick_save")
		if success:
			show_save_notification("Quick Load", "Game loaded successfully!")
			# Reload the scene to apply loaded data
			call_deferred("_reload_scene_with_save_data")
		else:
			show_save_notification("Quick Load", "Failed to load game!")
	else:
		show_save_notification("Quick Load", "No quick save found!")

func _reload_scene_with_save_data():
	"""Reload the scene and apply save data"""
	# This will be called after the scene is reloaded
	# The save data will be applied by the SaveManager
	SceneManager.goto_tower_defense()

func show_save_dialog():
	"""Show save game dialog"""
	# Create save dialog
	var save_dialog = AcceptDialog.new()
	save_dialog.title = "Save Game"
	save_dialog.size = Vector2(400, 200)
	
	# Create input field for save name
	var vbox = VBoxContainer.new()
	save_dialog.add_child(vbox)
	
	var label = Label.new()
	label.text = "Enter save name:"
	vbox.add_child(label)
	
	var input = LineEdit.new()
	input.placeholder_text = "Save name"
	input.text = "save_" + str(Time.get_unix_time_from_system())
	vbox.add_child(input)
	
	# Create buttons
	var button_container = HBoxContainer.new()
	vbox.add_child(button_container)
	
	var save_button = Button.new()
	save_button.text = "Save"
	save_button.pressed.connect(func(): _save_with_name(input.text, save_dialog))
	button_container.add_child(save_button)
	
	var cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(save_dialog.queue_free)
	button_container.add_child(cancel_button)
	
	# Add to scene
	var ui_canvas = $UI
	ui_canvas.add_child(save_dialog)
	
	# Center the dialog
	var window_size = Vector2(get_viewport().get_visible_rect().size)
	save_dialog.position = (window_size - Vector2(save_dialog.size)) / 2
	
	# Focus the input field
	input.grab_focus()

func show_load_dialog():
	"""Show load game dialog"""
	# Create load dialog
	var load_dialog = AcceptDialog.new()
	load_dialog.title = "Load Game"
	load_dialog.size = Vector2(500, 400)
	
	# Create scrollable list of save files
	var vbox = VBoxContainer.new()
	load_dialog.add_child(vbox)
	
	var label = Label.new()
	label.text = "Select save file to load:"
	vbox.add_child(label)
	
	var scroll_container = ScrollContainer.new()
	scroll_container.size = Vector2(450, 250)
	vbox.add_child(scroll_container)
	
	var save_list = VBoxContainer.new()
	scroll_container.add_child(save_list)
	
	# Get save files
	var save_files = GameManager.get_save_files()
	
	if save_files.is_empty():
		var no_saves_label = Label.new()
		no_saves_label.text = "No save files found"
		save_list.add_child(no_saves_label)
	else:
		for save_name in save_files:
			var save_info = GameManager.get_save_file_info(save_name)
			var save_button = Button.new()
			
			# Format save info
			var timestamp = Time.get_datetime_string_from_unix_time(save_info.get("timestamp", 0))
			var honey = save_info.get("honey", 0)
			var level = save_info.get("player_level", 1)
			
			save_button.text = save_name + " - Level " + str(level) + " - " + str(honey) + " Honey - " + timestamp
			save_button.pressed.connect(func(): _load_save_file(save_name, load_dialog))
			save_list.add_child(save_button)
	
	# Create buttons
	var button_container = HBoxContainer.new()
	vbox.add_child(button_container)
	
	var cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(load_dialog.queue_free)
	button_container.add_child(cancel_button)
	
	# Add to scene
	var ui_canvas = $UI
	ui_canvas.add_child(load_dialog)
	
	# Center the dialog
	var window_size = Vector2(get_viewport().get_visible_rect().size)
	load_dialog.position = (window_size - Vector2(load_dialog.size)) / 2

func _save_with_name(save_name: String, dialog: AcceptDialog):
	"""Save game with specified name"""
	if save_name.strip_edges() == "":
		show_save_notification("Save Error", "Please enter a save name!")
		return
	
	var success = GameManager.save_game(save_name)
	if success:
		show_save_notification("Save Game", "Game saved as: " + save_name)
		dialog.queue_free()
	else:
		show_save_notification("Save Error", "Failed to save game!")

func _load_save_file(save_name: String, dialog: AcceptDialog):
	"""Load specified save file"""
	var success = GameManager.load_game(save_name)
	if success:
		show_save_notification("Load Game", "Game loaded: " + save_name)
		dialog.queue_free()
		# Reload the scene to apply loaded data
		call_deferred("_reload_scene_with_save_data")
	else:
		show_save_notification("Load Error", "Failed to load game!")

func show_save_notification(title: String, message: String):
	"""Show a save/load notification"""
	var notification = AcceptDialog.new()
	notification.title = title
	notification.dialog_text = message
	notification.size = Vector2(300, 100)
	
	# Add to scene
	var ui_canvas = $UI
	ui_canvas.add_child(notification)
	
	# Center the notification
	var window_size = Vector2(get_viewport().get_visible_rect().size)
	notification.position = (window_size - Vector2(notification.size)) / 2
	
	# Auto-close after 2 seconds
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(notification.queue_free)

func check_for_pending_save_data():
	"""Check if there's pending save data to load"""
	if SaveManager.has_pending_tower_defense_data():
		var save_data = SaveManager.get_pending_tower_defense_data()
		load_tower_defense_data(save_data)
		print("Loaded pending tower defense save data")

func start_wave_composition_timer():
	"""Start timer to update wave composition in real-time"""
	if not has_node("WaveCompositionTimer"):
		var timer = Timer.new()
		timer.name = "WaveCompositionTimer"
		timer.wait_time = 0.5  # Update every 0.5 seconds
		timer.timeout.connect(_on_wave_composition_timer_timeout)
		add_child(timer)
	
	var timer = get_node("WaveCompositionTimer")
	if timer:
		timer.start()

func stop_wave_composition_timer():
	"""Stop the wave composition timer"""
	if has_node("WaveCompositionTimer"):
		var timer = get_node("WaveCompositionTimer")
		if timer:
			timer.stop()

func _on_wave_composition_timer_timeout():
	"""Update wave composition display in real-time"""
	if wave_composition_label and wave_manager and wave_manager.is_wave_in_progress():
		var composition = wave_manager.get_wave_composition(current_wave)
		if composition != "":
			wave_composition_label.text = "Wave " + str(current_wave) + ": " + composition
		else:
			wave_composition_label.text = ""

func game_over():
	print("Game Over!")
	# TODO: Show game over screen

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
		print("❌ FAILED: No tower placer available")

	return false

func test_lightning_flower_selection() -> bool:
	"""Test Lightning Flower selection"""
	if not tower_placer or tower_placer.placed_towers.size() == 0:
		print("❌ FAILED: No towers available for selection")
		return false

	var lightning_flower = null
	for tower in tower_placer.placed_towers:
		if tower and tower.tower_name == "Lightning Flower":
			lightning_flower = tower
			break

	if not lightning_flower:
		print("❌ FAILED: No Lightning Flower found for selection")
		return false

	print("Attempting to select Lightning Flower at: ", lightning_flower.global_position)

	# Clear any existing selection first
	clear_tower_selection()
	await get_tree().process_frame

	# Select the Lightning Flower
	select_tower(lightning_flower)
	await get_tree().process_frame

	# Check if selection worked
	if selected_tower == lightning_flower:
		print("✅ Lightning Flower selected successfully")
		return true
	else:
		print("❌ FAILED: Lightning Flower selection failed")

	return false

func test_lightning_flower_range_indicator() -> bool:
	"""Test Lightning Flower range indicator"""
	# Range indicator should exist after selection
	if range_indicator:
		print("✅ Range indicator exists: ", range_indicator.name)

		# Check if it has visual components
		if range_indicator.get_child_count() > 0:
			print("✅ Range indicator has visual components")

			# Check position
			if selected_tower:
				var distance = range_indicator.global_position.distance_to(selected_tower.global_position)
				if distance < 10:  # Should be very close
					print("✅ Range indicator positioned correctly")
					return true
				else:
					print("❌ FAILED: Range indicator position mismatch (distance: %.1f)" % distance)
			else:
				print("❌ FAILED: No selected tower for position comparison")
		else:
			print("❌ FAILED: Range indicator has no visual components")
	else:
		print("❌ FAILED: No range indicator found")

	return false

# =============================================================================
# METAPROGRESSION FIELDS - EMPTY 2x2 FIELDS OUTSIDE PLAY AREA
# =============================================================================

func setup_metaprogression_fields():
	"""Setup five empty 2x2 fields in a horizontal line below the play area"""
	print("Setting up metaprogression fields...")
	
	# Calculate positions for 5 fields in a horizontal line below the play area
	# Play area is 20x15 (640x480 pixels), so below it starts at row 15
	# Center the fields horizontally with equal spacing
	var start_x = 2  # Start 2 tiles from left edge
	var field_spacing = 3  # 3 tiles between field centers (1 tile gap between fields)
	var row_y = 16  # One row below the play area
	
	var field_positions = []
	for i in range(5):
		var x_pos = start_x + (i * field_spacing)
		field_positions.append(Vector2(x_pos, row_y))
	
	var map_offset = get_meta("map_offset", Vector2.ZERO)
	
	for i in range(field_positions.size()):
		var field_pos = field_positions[i]
		create_metaprogression_field(field_pos, map_offset, i + 1)
	
	# Assign random towers to each field
	assign_random_towers_to_fields()
	
	print("Metaprogression fields setup complete!")

func create_metaprogression_field(grid_pos: Vector2, map_offset: Vector2, field_number: int):
	"""Create an empty 2x2 field outside the play area"""
	print("Creating metaprogression field %d at grid position %s" % [field_number, grid_pos])
	
	# Calculate world position (2x2 field = 64x64 pixels)
	var world_pos = Vector2(grid_pos.x * 32, grid_pos.y * 32) + map_offset
	
	# Create field background
	var field_background = ColorRect.new()
	field_background.name = "MetaprogressionField_%d" % field_number
	field_background.size = Vector2(64, 64)  # 2x2 tiles
	field_background.position = world_pos
	field_background.color = Color(0.2, 0.2, 0.4, 0.6)  # Dark blue for metaprogression
	field_background.z_index = -3  # Above path but below other elements
	$UI.add_child(field_background)
	
	# Create border for the field
	create_field_border(field_background, world_pos)
	
	# Create field label
	create_field_label(field_background, world_pos, field_number)
	
	print("Metaprogression field %d created at %s (empty)" % [field_number, world_pos])

func assign_random_towers_to_fields():
	"""Assign random towers to each metaprogression field"""
	print("Assigning random towers to metaprogression fields...")
	
	# Define the four basic tower types
	var tower_types = ["stinger", "propolis_bomber", "nectar_sprayer", "lightning_flower"]
	
	# Clear existing towers
	metaprogression_towers.clear()
	
	# Calculate field positions (same as in setup_metaprogression_fields)
	var start_x = 2
	var field_spacing = 3
	var row_y = 16
	var map_offset = get_meta("map_offset", Vector2.ZERO)
	
	for i in range(5):
		# Get random tower type
		var random_tower_type = tower_types[randi() % tower_types.size()]
		
		# Calculate field position
		var field_x = start_x + (i * field_spacing)
		var field_pos = Vector2(field_x, row_y)
		var world_pos = Vector2(field_pos.x * 32, field_pos.y * 32) + map_offset
		
		# Create tower in field
		var tower = create_metaprogression_tower(random_tower_type, world_pos, i + 1)
		if tower:
			metaprogression_towers.append(tower)
			print("Field %d: Assigned %s tower" % [i + 1, random_tower_type])
	
	print("Random tower assignment complete!")

func create_metaprogression_tower(tower_type: String, world_pos: Vector2, field_number: int) -> Tower:
	"""Create a tower in a metaprogression field"""
	print("Creating %s tower in field %d at %s" % [tower_type, field_number, world_pos])
	
	var tower: Tower
	var tower_name: String
	
	# Create the appropriate tower instance directly
	match tower_type:
		"stinger":
			tower = StingerTower.new()
			tower_name = "Stinger Tower"
		"propolis_bomber":
			tower = PropolisBomberTower.new()
			tower_name = "Propolis Bomber Tower"
		"nectar_sprayer":
			tower = NectarSprayerTower.new()
			tower_name = "Nectar Sprayer Tower"
		"lightning_flower":
			tower = LightningFlowerTower.new()
			tower_name = "Lightning Flower Tower"
		_:
			print("Unknown tower type: %s" % tower_type)
			return null
	
	if not tower:
		print("Failed to create tower instance for type: %s" % tower_type)
		return null
	
	# Set tower properties
	tower.name = "MetaprogressionTower_%d" % field_number
	tower.position = world_pos
	tower.tower_name = tower_name
	
	print("=== CREATING METAPROGRESSION TOWER ===")
	print("Tower name: %s" % tower_name)
	print("World position: %s" % world_pos)
	print("Tower position after setting: %s" % tower.position)
	print("Tower global position: %s" % tower.global_position)
	
	# Add to scene - try adding to UI canvas instead of main scene
	var ui_canvas = $UI
	ui_canvas.add_child(tower)
	
	print("Tower position after add_child: %s" % tower.position)
	print("Tower global position after add_child: %s" % tower.global_position)
	
	# Make tower clickable for pickup
	tower.set_meta("is_metaprogression_tower", true)
	tower.set_meta("field_number", field_number)
	
	print("Metaprogression tower created: %s in field %d" % [tower_name, field_number])
	print("=== TOWER CREATION COMPLETE ===")
	return tower

# =============================================================================
# METAPROGRESSION TOWER PICKUP SYSTEM
# =============================================================================

func handle_metaprogression_tower_pickup(click_position: Vector2) -> bool:
	"""Handle pickup of metaprogression towers"""
	print("Checking for metaprogression tower pickup at: %s" % click_position)
	
	# Check if we're already holding a tower
	if picked_up_tower != null:
		# Try to place the picked up tower
		if try_place_picked_up_tower(click_position):
			return true
		return false
	
	# Check for metaprogression towers at click position
	for tower in metaprogression_towers:
		if tower and is_instance_valid(tower):
			var distance = click_position.distance_to(tower.global_position)
			if distance < 32:  # Within tower radius
				pickup_metaprogression_tower(tower)
				return true
	
	return false

func pickup_metaprogression_tower(tower: Tower):
	"""Pick up a metaprogression tower"""
	print("=== PICKING UP METAPROGRESSION TOWER ===")
	print("Tower name: %s" % tower.tower_name)
	print("Tower original position: %s" % tower.global_position)
	print("Mouse position: %s" % get_global_mouse_position())
	
	# Store the picked up tower
	picked_up_tower = tower
	
	# Hide the original tower
	tower.visible = false
	
	# Create a new tower at mouse position
	var mouse_pos = get_global_mouse_position()
	var new_tower = create_tower_at_position(tower.tower_name, mouse_pos)
	if new_tower:
		picked_up_tower = new_tower
		print("New tower created at mouse position: %s" % new_tower.global_position)
	
	# Show range indicator at mouse position
	show_tower_range_at_mouse_position(picked_up_tower)
	
	# Create a visual indicator that we're holding a tower
	create_pickup_indicator(picked_up_tower)
	
	# Start following mouse position
	start_tower_following_mouse()
	
	print("Metaprogression tower picked up: %s" % picked_up_tower.tower_name)
	print("=== PICKUP COMPLETE ===")

func try_place_picked_up_tower(click_position: Vector2) -> bool:
	"""Try to place the picked up tower at the click position"""
	if picked_up_tower == null:
		return false
	
	print("Trying to place picked up tower at: %s" % click_position)
	
	# Check if position is valid for tower placement
	if is_valid_tower_placement_position(click_position):
		# Place the tower
		place_picked_up_tower(click_position)
		return true
	else:
		# Return tower to original position
		return_picked_up_tower()
		return false

func is_valid_tower_placement_position(position: Vector2) -> bool:
	"""Check if position is valid for tower placement"""
	# Check if position is within the play area (20x15 grid)
	var grid_pos = Vector2(int(position.x / 32), int(position.y / 32))
	
	# Play area is 20x15 (0-19 x 0-14)
	if grid_pos.x < 0 or grid_pos.x >= 20 or grid_pos.y < 0 or grid_pos.y >= 15:
		print("Position outside play area: %s" % grid_pos)
		return false
	
	# Check if position is not on the path
	if is_position_on_path(position):
		print("Position on path: %s" % position)
		return false
	
	# Check if position is not occupied by another tower
	if is_position_occupied(position):
		print("Position occupied: %s" % position)
		return false
	
	return true

func is_position_on_path(position: Vector2) -> bool:
	"""Check if position is on the enemy path"""
	# This is a simplified check - you might want to implement a more sophisticated path detection
	var grid_pos = Vector2(int(position.x / 32), int(position.y / 32))
	
	# Define path positions (simplified)
	var path_positions = [
		Vector2(0, 7), Vector2(1, 7), Vector2(2, 7), Vector2(3, 7), Vector2(4, 7), Vector2(5, 7),
		Vector2(5, 8), Vector2(5, 9), Vector2(5, 10), Vector2(5, 11),
		Vector2(6, 11), Vector2(7, 11), Vector2(8, 11), Vector2(9, 11), Vector2(10, 11), Vector2(11, 11), Vector2(12, 11), Vector2(13, 11), Vector2(14, 11),
		Vector2(14, 10), Vector2(14, 9), Vector2(14, 8), Vector2(14, 7), Vector2(14, 6), Vector2(14, 5), Vector2(14, 4), Vector2(14, 3),
		Vector2(15, 3), Vector2(16, 3), Vector2(17, 3), Vector2(18, 3), Vector2(19, 3)
	]
	
	return grid_pos in path_positions

func is_position_occupied(position: Vector2) -> bool:
	"""Check if position is occupied by another tower"""
	# Check tower placer towers
	if tower_placer and tower_placer.placed_towers:
		for tower in tower_placer.placed_towers:
			if tower and is_instance_valid(tower):
				var distance = position.distance_to(tower.position)
				if distance < 32:  # Within tower radius
					return true
	
	return false

func place_picked_up_tower(position: Vector2):
	"""Place the picked up tower at the specified position"""
	print("Placing picked up tower at: %s" % position)
	
	if picked_up_tower == null:
		return
	
	# Align position to grid (32x32 tiles)
	var grid_pos = Vector2(int(position.x / 32), int(position.y / 32))
	var aligned_position = Vector2(grid_pos.x * 32, grid_pos.y * 32)
	
	print("Original position: %s, Grid position: %s, Aligned position: %s" % [position, grid_pos, aligned_position])
	
	# Move tower from UI canvas to main scene for proper placement
	var ui_canvas = $UI
	if picked_up_tower.get_parent() == ui_canvas:
		ui_canvas.remove_child(picked_up_tower)
		add_child(picked_up_tower)
		# Reset z_index for main scene placement
		picked_up_tower.z_index = 0
		print("Moved tower from UI canvas to main scene for placement")
	
	# Set tower position to aligned grid position AFTER moving to main scene
	picked_up_tower.global_position = aligned_position
	
	# Make tower visible
	picked_up_tower.visible = true
	
	print("Tower positioned at: %s (aligned from %s)" % [picked_up_tower.global_position, position])
	
	# Verify tower is properly positioned
	print("Tower final position: %s" % picked_up_tower.global_position)
	print("Tower parent: %s" % picked_up_tower.get_parent().name)
	print("Tower visible: %s" % picked_up_tower.visible)
	
	# Remove metaprogression tower metadata
	picked_up_tower.remove_meta("is_metaprogression_tower")
	picked_up_tower.remove_meta("field_number")
	
	# Add to tower placer
	if tower_placer:
		tower_placer.placed_towers.append(picked_up_tower)
		print("Tower added to tower_placer.placed_towers")
	else:
		print("WARNING: tower_placer is null!")
	
	# Remove from metaprogression towers
	metaprogression_towers.erase(picked_up_tower)
	
	# Clear picked up tower
	picked_up_tower = null
	
	# Stop mouse following and remove indicators
	stop_tower_following_mouse()
	remove_pickup_indicator()
	clear_range_indicator()
	
	print("Metaprogression tower placed successfully!")

func return_picked_up_tower():
	"""Return the picked up tower to its original position"""
	print("Returning picked up tower to original position")
	
	if picked_up_tower == null:
		return
	
	# Make tower visible again
	picked_up_tower.visible = true
	
	# Clear picked up tower
	picked_up_tower = null
	
	# Stop mouse following and remove indicators
	stop_tower_following_mouse()
	remove_pickup_indicator()
	clear_range_indicator()
	
	print("Metaprogression tower returned to original position")

func create_pickup_indicator(tower: Tower):
	"""Create visual indicator for picked up tower"""
	# This could be a cursor change, visual effect, or UI indicator
	print("Creating pickup indicator for: %s" % tower.tower_name)
	# Implementation depends on desired visual feedback

func remove_pickup_indicator():
	"""Remove pickup indicator"""
	print("Removing pickup indicator")
	# Implementation depends on desired visual feedback

func create_tower_at_position(tower_name: String, position: Vector2) -> Tower:
	"""Create a tower at a specific position"""
	print("Creating tower at position: %s" % position)
	
	var tower: Tower
	var tower_type: String
	
	# Determine tower type from name
	if "Stinger" in tower_name:
		tower = StingerTower.new()
		tower_type = "stinger"
	elif "Propolis Bomber" in tower_name:
		tower = PropolisBomberTower.new()
		tower_type = "propolis_bomber"
	elif "Nectar Sprayer" in tower_name:
		tower = NectarSprayerTower.new()
		tower_type = "nectar_sprayer"
	elif "Lightning Flower" in tower_name:
		tower = LightningFlowerTower.new()
		tower_type = "lightning_flower"
	else:
		print("Unknown tower name: %s" % tower_name)
		return null
	
	if not tower:
		print("Failed to create tower instance")
		return null
	
	# Set tower properties
	tower.name = "PickedUpTower"
	tower.tower_name = tower_name
	tower.global_position = position
	
	print("Tower created at: %s" % tower.global_position)
	
	# Add to main scene instead of UI canvas
	add_child(tower)
	
	# Force position update after adding to scene
	tower.global_position = position
	
	print("Tower added to main scene at: %s" % tower.global_position)
	
	return tower


func create_random_tower_at_mouse_position():
	"""Create a random tower at mouse position when no metaprogression tower is nearby"""
	print("=== CREATING RANDOM TOWER AT MOUSE POSITION ===")
	
	var mouse_pos = get_global_mouse_position()
	
	# Define available tower types
	var tower_types = ["Stinger Tower", "Propolis Bomber Tower", "Nectar Sprayer Tower", "Lightning Flower Tower"]
	var random_tower_name = tower_types[randi() % tower_types.size()]
	
	print("Creating random tower: %s at mouse position: %s" % [random_tower_name, mouse_pos])
	
	# Create tower at mouse position
	var new_tower = create_tower_at_position(random_tower_name, mouse_pos)
	if new_tower:
		picked_up_tower = new_tower
		
		# Show range indicator
		show_tower_range_at_mouse_position(new_tower)
		
		# Start following mouse
		start_tower_following_mouse()
		
		print("Random tower created and picked up: %s" % random_tower_name)
	else:
		print("Failed to create random tower")

func handle_tower_hotkey(tower_type: String, tower_name: String):
	"""Handle tower hotkey with unified logic"""
	print("=== HANDLING TOWER HOTKEY ===")
	print("Tower type: %s, Tower name: %s" % [tower_type, tower_name])
	
	# Check if we're already holding a tower (mouse following mode)
	if picked_up_tower != null:
		print("Already holding a tower, trying to place it")
		# Try to place the picked up tower at mouse position
		var mouse_pos = get_global_mouse_position()
		if try_place_picked_up_tower(mouse_pos):
			print("Tower placed successfully via hotkey")
		else:
			print("Failed to place tower, returning to original position")
			return_picked_up_tower()
		return
	
	# Check if we're already in placement mode for this tower type
	if is_in_tower_placement and current_tower_type == tower_type:
		print("Already in placement mode for %s, canceling placement" % tower_type)
		tower_placer.cancel_placement()
		return
	
	# Start unified tower placement system
	start_unified_tower_placement(tower_type, tower_name)

func cleanup_mouse_following_system():
	"""Clean up any existing mouse following system"""
	print("=== CLEANING UP MOUSE FOLLOWING SYSTEM ===")
	
	# Stop mouse following
	stop_tower_following_mouse()
	
	# Clear picked up tower
	if picked_up_tower != null:
		print("Clearing picked up tower: %s" % picked_up_tower.tower_name)
		if is_instance_valid(picked_up_tower):
			picked_up_tower.queue_free()
		picked_up_tower = null
	
	# Clear range indicator
	clear_range_indicator()
	
	# Remove pickup indicator
	remove_pickup_indicator()
	
	print("Mouse following system cleaned up")

func start_unified_tower_placement(tower_type: String, tower_name: String):
	"""Start unified tower placement system"""
	print("=== STARTING UNIFIED TOWER PLACEMENT ===")
	print("Tower type: %s, Tower name: %s" % [tower_type, tower_name])
	
	# Get current mouse position
	var mouse_pos = get_global_mouse_position()
	print("Mouse position: %s" % mouse_pos)
	
	# Create tower at mouse position
	var tower = create_unified_tower(tower_name, mouse_pos)
	if not tower:
		print("Failed to create unified tower")
		return
	
	# Set up mouse following
	picked_up_tower = tower
	start_tower_following_mouse()
	
	# Show range indicator
	show_tower_range_at_mouse_position(tower)
	
	print("Unified tower placement started for: %s" % tower_name)

func create_unified_tower(tower_name: String, position: Vector2) -> Tower:
	"""Create a tower with unified positioning system"""
	print("=== CREATING UNIFIED TOWER ===")
	print("Tower name: %s, Position: %s" % [tower_name, position])
	
	var tower: Tower
	var tower_type: String
	
	# Determine tower type from name
	if "Stinger" in tower_name:
		tower = StingerTower.new()
		tower_type = "stinger"
	elif "Propolis Bomber" in tower_name:
		tower = PropolisBomberTower.new()
		tower_type = "propolis_bomber"
	elif "Nectar Sprayer" in tower_name:
		tower = NectarSprayerTower.new()
		tower_type = "nectar_sprayer"
	elif "Lightning Flower" in tower_name:
		tower = LightningFlowerTower.new()
		tower_type = "lightning_flower"
	else:
		print("Unknown tower name: %s" % tower_name)
		return null
	
	if not tower:
		print("Failed to create tower instance")
		return null
	
	# Set tower properties
	tower.name = "UnifiedTower_" + tower_type
	tower.tower_name = tower_name
	
	# Initialize tower properties
	if tower.has_method("_ready"):
		tower._ready()
	
	# Add to UI canvas instead of main scene for better visibility
	var ui_canvas = $UI
	ui_canvas.add_child(tower)
	
	# Set position after adding to scene
	tower.global_position = position
	
	# Set high z_index to ensure visibility above game area
	tower.z_index = 100
	
	print("Tower added to UI canvas with z_index: %d" % tower.z_index)
	print("Tower initialized: %s" % tower.tower_name)
	
	print("Unified tower created: %s at %s with z_index: %d" % [tower_name, tower.global_position, tower.z_index])
	
	return tower

func test_tower_positioning():
	"""Test function to validate tower positioning system"""
	print("=== TESTING TOWER POSITIONING SYSTEM ===")
	
	# Test mouse position
	var mouse_pos = get_global_mouse_position()
	print("Current mouse position: %s" % mouse_pos)
	
	# Test viewport size
	var viewport_size = get_viewport().get_visible_rect().size
	print("Viewport size: %s" % viewport_size)
	
	# Test if mouse position is within viewport
	if mouse_pos.x >= 0 and mouse_pos.x <= viewport_size.x and mouse_pos.y >= 0 and mouse_pos.y <= viewport_size.y:
		print("Mouse position is within viewport bounds")
	else:
		print("WARNING: Mouse position is outside viewport bounds")
	
	# Test coordinate system
	print("Global mouse position: %s" % get_global_mouse_position())
	print("Local mouse position: %s" % get_local_mouse_position())
	
	print("=== TOWER POSITIONING TEST COMPLETE ===")

func create_tower_at_mouse_position(tower_name: String):
	"""Create a tower at mouse position via hotkey"""
	print("=== CREATING TOWER AT MOUSE POSITION VIA HOTKEY ===")
	print("Tower name: %s" % tower_name)
	
	# Check if we're already holding a tower
	if picked_up_tower != null:
		print("Already holding a tower, trying to place it")
		# Try to place the picked up tower at mouse position
		var mouse_pos = get_global_mouse_position()
		if try_place_picked_up_tower(mouse_pos):
			print("Tower placed successfully via hotkey")
		else:
			print("Failed to place tower, returning to original position")
			return_picked_up_tower()
		return
	
	var mouse_pos = get_global_mouse_position()
	print("Creating tower: %s at mouse position: %s" % [tower_name, mouse_pos])
	
	# Create tower at mouse position
	var new_tower = create_tower_at_position(tower_name, mouse_pos)
	if new_tower:
		picked_up_tower = new_tower
		
		# Show range indicator
		show_tower_range_at_mouse_position(new_tower)
		
		# Start following mouse
		start_tower_following_mouse()
		
		print("Tower created and picked up: %s" % tower_name)
	else:
		print("Failed to create tower")

# =============================================================================
# TOWER MOUSE FOLLOWING SYSTEM
# =============================================================================

func start_tower_following_mouse():
	"""Start making the picked up tower follow the mouse"""
	if picked_up_tower == null:
		return
	
	# Set initial position to mouse position immediately
	var mouse_pos = get_global_mouse_position()
	picked_up_tower.global_position = mouse_pos
	print("Set initial tower position to mouse: %s" % mouse_pos)
	
	# Connect to the _process function to update position
	set_process(true)
	print("Started tower following mouse")

func stop_tower_following_mouse():
	"""Stop making the tower follow the mouse"""
	set_process(false)
	print("Stopped tower following mouse")

func _process(delta):
	"""Update picked up tower position to follow mouse"""
	# Only run if we have a picked up tower and we're not in normal placement mode
	if picked_up_tower != null and is_instance_valid(picked_up_tower) and not is_in_tower_placement:
		var mouse_pos = get_global_mouse_position()
		var old_pos = picked_up_tower.global_position
		
		# Update tower position to mouse position
		picked_up_tower.global_position = mouse_pos
		
		# Debug: Print position changes (less verbose)
		if old_pos.distance_to(mouse_pos) > 10.0:  # Only print if moved significantly
			print("Tower moved from %s to %s" % [old_pos, mouse_pos])
		
		# Update range indicator position as well
		if range_indicator != null and is_instance_valid(range_indicator):
			range_indicator.global_position = mouse_pos
			# Ensure range indicator stays above tower
			range_indicator.z_index = picked_up_tower.z_index + 1
	else:
		# If we're in normal placement mode, stop the process
		if is_in_tower_placement:
			set_process(false)

func show_tower_range_at_mouse_position(tower: Tower):
	"""Show range indicator at mouse position for picked up tower"""
	print("=== SHOWING TOWER RANGE AT MOUSE POSITION ===")
	
	# Validate tower before proceeding
	if not tower or not is_instance_valid(tower):
		print("ERROR: Invalid tower in show_tower_range_at_mouse_position")
		return
	
	print("Tower: ", tower.tower_name, " with range: ", tower.range)
	
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
	
	# Position at mouse position immediately
	var mouse_pos = get_global_mouse_position()
	range_indicator.global_position = mouse_pos
	range_indicator.z_index = 101  # Higher than tower to ensure visibility
	
	# Add to UI canvas for better visibility
	var ui_canvas = $UI
	ui_canvas.add_child(range_indicator)
	
	# Force position update after adding to scene
	range_indicator.global_position = mouse_pos
	
	# Verify position was set correctly
	print("Range indicator final position: %s" % range_indicator.global_position)
	
	print("Range indicator created: ", range_indicator.name, " at mouse position: ", range_indicator.global_position, " with range: ", tower.range)
	print("=== RANGE INDICATOR SETUP COMPLETE ===")

func create_field_border(field_background: ColorRect, world_pos: Vector2):
	"""Create a border around the metaprogression field"""
	var border = ColorRect.new()
	border.name = "FieldBorder"
	border.size = Vector2(64, 64)
	border.position = world_pos
	border.color = Color(0.0, 0.0, 0.0, 0.0)  # Transparent background
	
	# Create border using Line2D
	var border_line = Line2D.new()
	border_line.width = 2.0
	border_line.default_color = Color.CYAN
	border_line.z_index = 1
	
	# Create rectangle border
	var border_points = PackedVector2Array([
		Vector2(0, 0),
		Vector2(64, 0),
		Vector2(64, 64),
		Vector2(0, 64),
		Vector2(0, 0)
	])
	border_line.points = border_points
	border.add_child(border_line)
	
	field_background.add_child(border)

func create_field_label(field_background: ColorRect, world_pos: Vector2, field_number: int):
	"""Create a label for the metaprogression field"""
	var label = Label.new()
	label.name = "FieldLabel"
	label.text = "Field " + str(field_number)
	label.position = Vector2(8, 20)  # Position within the field
	label.size = Vector2(48, 24)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	field_background.add_child(label)

# Metaprogression fields are now empty by design
# Towers will be added later through the metaprogression system

# =============================================================================
# AUTOMATIC WAVE STARTING SYSTEM
# =============================================================================

func start_automatic_next_wave():
	"""Start the next wave automatically after a delay based on speed mode"""
	var delay_seconds = get_wave_delay_for_speed_mode()
	
	print("Starting automatic next wave in %.1f seconds (speed mode: %d)" % [delay_seconds, speed_mode])
	
	# Set countdown and start visual countdown
	countdown_seconds = delay_seconds
	start_wave_countdown_display()
	
	# Create and start timer for automatic wave start
	var timer = Timer.new()
	timer.name = "AutoWaveTimer"
	timer.wait_time = delay_seconds
	timer.one_shot = true
	timer.timeout.connect(_on_auto_wave_timer_timeout)
	add_child(timer)
	timer.start()
	
	# Update UI to show countdown
	update_wave_countdown_ui(delay_seconds)

func get_wave_delay_for_speed_mode() -> float:
	"""Get the delay in seconds for the next wave based on current speed mode"""
	match speed_mode:
		0:  # Normal speed (1x)
			return 15.0
		1:  # Double speed (2x)
			return 10.0
		2:  # Triple speed (3x)
			return 5.0
		_:
			return 15.0

func _on_auto_wave_timer_timeout():
	"""Called when the automatic wave timer expires"""
	print("Auto wave timer expired - starting next wave")
	
	# Stop countdown display
	stop_wave_countdown_display()
	
	# Clean up the timer
	var timer = get_node("AutoWaveTimer")
	if timer:
		timer.queue_free()
	
	# Start the next wave
	wave_manager.start_wave(current_wave)
	
	# Update UI
	update_ui()

func update_wave_countdown_ui(delay_seconds: float):
	"""Update UI to show countdown for next wave"""
	# This could be expanded to show a countdown timer in the UI
	print("Next wave will start in %.1f seconds" % delay_seconds)

func stop_auto_wave_timer():
	"""Stop the automatic wave timer if it exists"""
	var timer = get_node_or_null("AutoWaveTimer")
	if timer:
		timer.queue_free()
		print("Auto wave timer stopped")
	
	# Stop countdown display
	stop_wave_countdown_display()

# =============================================================================
# WAVE COUNTDOWN DISPLAY SYSTEM
# =============================================================================

func start_wave_countdown_display():
	"""Start the visual countdown display"""
	if wave_countdown_timer:
		wave_countdown_timer.start()
		update_countdown_display()

func stop_wave_countdown_display():
	"""Stop the visual countdown display"""
	if wave_countdown_timer:
		wave_countdown_timer.stop()
	
	if wave_countdown_label:
		wave_countdown_label.text = ""

func _on_wave_countdown_timer_timeout():
	"""Update countdown display every second"""
	if countdown_seconds > 0:
		countdown_seconds -= 1.0
		update_countdown_display()
	else:
		stop_wave_countdown_display()

func update_countdown_display():
	"""Update the countdown display text"""
	if wave_countdown_label and countdown_seconds > 0:
		var minutes = int(countdown_seconds) / 60
		var seconds = int(countdown_seconds) % 60
		
		if minutes > 0:
			wave_countdown_label.text = "Next wave in %d:%02d" % [minutes, seconds]
		else:
			wave_countdown_label.text = "Next wave in %d seconds" % [int(countdown_seconds)]
	elif wave_countdown_label:
		wave_countdown_label.text = ""
