class_name TowerPlacer
extends Node2D

signal tower_placed(tower, position)
signal tower_placement_failed(reason)
signal placement_mode_changed(is_active)

enum PlacementMode {
	NONE,
	PLACING_TOWER,
	SELECTING_TOWER
}

# Tower placement settings
@export var grid_size: int = 32
@export var show_grid: bool = true
@export var show_range_preview: bool = true

# Current state
var current_mode: PlacementMode = PlacementMode.NONE
var selected_tower_type: String = ""
var placement_preview: Node2D = null
var range_preview: Node2D = null

# References
var tower_defense_scene: Node2D
var build_layer: TileMapLayer
var placed_towers: Array[Tower] = []

# Available tower types
var available_towers: Dictionary = {
	"basic_shooter": {
		"name": "Basic Shooter",
		"script": "res://scripts/BasicShooterTower.gd",
		"cost": 25,
		"description": "A simple offensive tower that shoots projectiles"
	}
}

func _ready():
	tower_defense_scene = get_parent()
	if tower_defense_scene.has_method("get_node"):
		build_layer = tower_defense_scene.get_node("Map/BuildLayer")

func _input(event):
	if current_mode == PlacementMode.PLACING_TOWER:
		handle_placement_input(event)
	elif current_mode == PlacementMode.SELECTING_TOWER:
		handle_selection_input(event)

func handle_placement_input(event):
	if event is InputEventMouseMotion:
		update_placement_preview(event.position)
	elif event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				print("Left click detected for tower placement!")
				attempt_tower_placement(event.position)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				print("Right click detected - cancelling placement")
				cancel_placement()

func handle_selection_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			select_tower_at_position(event.position)

func start_tower_placement(tower_type: String):
	print("Starting tower placement for: ", tower_type)

	if tower_type not in available_towers:
		tower_placement_failed.emit("Invalid tower type: " + tower_type)
		return

	var tower_data = available_towers[tower_type]
	var cost = tower_data["cost"]
	var current_honey = GameManager.get_resource("honey")

	print("Tower cost: ", cost, " Current honey: ", current_honey)

	if current_honey < cost:
		tower_placement_failed.emit("Not enough honey! Need " + str(cost))
		return

	selected_tower_type = tower_type
	current_mode = PlacementMode.PLACING_TOWER
	create_placement_preview()
	placement_mode_changed.emit(true)

	print("Tower placement mode activated!")

func create_placement_preview():
	# Create preview tower in UI layer for visibility
	var td_scene = get_parent()
	var ui_canvas = td_scene.get_node("UI")

	placement_preview = Node2D.new()
	placement_preview.name = "TowerPlacementPreview"
	ui_canvas.add_child(placement_preview)

	# Create visual preview
	var preview_visual = ColorRect.new()
	preview_visual.size = Vector2(24, 24)
	preview_visual.position = Vector2(-12, -12)
	preview_visual.color = Color.GREEN
	preview_visual.modulate.a = 0.7
	preview_visual.z_index = 10  # Above everything
	placement_preview.add_child(preview_visual)

	# Create range preview
	create_range_preview()

	print("Tower placement preview created in UI layer")

func create_range_preview():
	if not show_range_preview:
		return

	range_preview = Node2D.new()
	placement_preview.add_child(range_preview)

	# Get tower data for range
	var tower_data = available_towers[selected_tower_type]
	var preview_range = 120.0  # Default range for preview

	# Create range circle
	var range_circle = Node2D.new()
	range_preview.add_child(range_circle)

	# Draw range circle using Line2D
	var line = Line2D.new()
	line.width = 2.0
	line.default_color = Color(0.5, 0.5, 1.0, 0.5)

	var points = []
	var segments = 32
	for i in range(segments + 1):
		var angle = i * 2 * PI / segments
		var point = Vector2(cos(angle), sin(angle)) * preview_range
		points.append(point)

	line.points = PackedVector2Array(points)
	range_circle.add_child(line)

func update_placement_preview(screen_pos: Vector2):
	if not placement_preview:
		return

	# Get mouse position (UI coordinates)
	var mouse_pos = get_global_mouse_position()
	var td_scene = get_parent()
	var map_offset = td_scene.get_meta("map_offset", Vector2.ZERO)

	# Convert from screen coordinates to map coordinates
	var map_pos = mouse_pos - map_offset
	var grid_pos = snap_to_grid(map_pos)

	# Place preview at UI position (with map offset)
	var ui_pos = grid_pos + map_offset
	placement_preview.global_position = ui_pos

	# Check if position is valid
	var is_valid = is_valid_placement_position(grid_pos)
	var preview_visual = placement_preview.get_child(0)
	preview_visual.color = Color.GREEN if is_valid else Color.RED

	print("Preview pos: UI=", ui_pos, " Map=", grid_pos, " Valid=", is_valid)

func snap_to_grid(pos: Vector2) -> Vector2:
	var grid_x = round(pos.x / grid_size) * grid_size
	var grid_y = round(pos.y / grid_size) * grid_size
	return Vector2(grid_x, grid_y)

func is_valid_placement_position(pos: Vector2) -> bool:
	# Simple grid-based validation for now
	var grid_x = int(pos.x / grid_size)
	var grid_y = int(pos.y / grid_size)

	# Check bounds
	if grid_x < 0 or grid_x >= 20 or grid_y < 0 or grid_y >= 15:
		return false

	# Don't allow building on the path (row 7)
	if grid_y == 7:
		return false

	# Check if there's already a tower here
	for tower in placed_towers:
		if tower.global_position.distance_to(pos) < grid_size / 2:
			return false

	return true

func attempt_tower_placement(screen_pos: Vector2):
	# Get mouse position relative to the map (accounting for map offset)
	var mouse_pos = get_global_mouse_position()
	var td_scene = get_parent()
	var map_offset = td_scene.get_meta("map_offset", Vector2.ZERO)

	# Convert from screen coordinates to map coordinates
	var map_pos = mouse_pos - map_offset
	var grid_pos = snap_to_grid(map_pos)

	if not is_valid_placement_position(grid_pos):
		tower_placement_failed.emit("Invalid placement position")
		return

	place_tower(grid_pos)

func place_tower(pos: Vector2):
	var tower_data = available_towers[selected_tower_type]
	var cost = tower_data["cost"]

	# Deduct resources
	GameManager.add_resource("honey", -cost)

	# Create tower instance
	var tower_script = load(tower_data["script"])
	var tower = tower_script.new() as Tower

	# Position tower at world coordinates (need to add map offset for UI positioning)
	var map_offset = tower_defense_scene.get_meta("map_offset", Vector2.ZERO)

	# Add tower to UI layer for visibility
	var ui_canvas = tower_defense_scene.get_node("UI")
	tower.global_position = pos + map_offset  # Convert to UI coordinates
	ui_canvas.add_child(tower)
	placed_towers.append(tower)

	# Connect tower signals
	tower.tower_destroyed.connect(_on_tower_destroyed)

	# Emit success signal
	tower_placed.emit(tower, pos)

	# Debug output
	print("Tower placed: " + tower_data["name"] + " at world pos " + str(pos))
	print("Tower node added to scene: ", tower_defense_scene.name)
	print("Tower children count: ", tower_defense_scene.get_children().size())

	# Continue placement or exit based on user preference
	# For now, continue placing the same tower type

func cancel_placement():
	current_mode = PlacementMode.NONE
	cleanup_preview()
	placement_mode_changed.emit(false)

func cleanup_preview():
	if placement_preview:
		placement_preview.queue_free()
		placement_preview = null
	range_preview = null

func select_tower_at_position(screen_pos: Vector2):
	# Get mouse position relative to the map (accounting for map offset)
	var mouse_pos = get_global_mouse_position()
	var td_scene = get_parent()
	var map_offset = td_scene.get_meta("map_offset", Vector2.ZERO)

	# Convert from screen coordinates to map coordinates
	var map_pos = mouse_pos - map_offset

	for tower in placed_towers:
		if tower.global_position.distance_to(map_pos) < grid_size:
			show_tower_info(tower)
			return

func show_tower_info(tower: Tower):
	print("Selected tower: ", tower.get_tower_info())
	# TODO: Show tower upgrade UI

func _on_tower_destroyed(tower: Tower):
	if tower in placed_towers:
		placed_towers.erase(tower)

func get_available_towers() -> Dictionary:
	return available_towers

func get_placed_towers() -> Array[Tower]:
	return placed_towers