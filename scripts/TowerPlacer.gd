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
	"stinger": {
		"name": "Stinger Tower",
		"script": "res://scripts/StingerTower.gd",
		"cost": 20,
		"description": "Fast-firing tower with high attack speed"
	},
	"propolis_bomber": {
		"name": "Propolis Bomber",
		"script": "res://scripts/PropolisBomberTower.gd",
		"cost": 45,
		"description": "Explosive projectiles with area damage"
	},
	"nectar_sprayer": {
		"name": "Nectar Sprayer",
		"script": "res://scripts/NectarSprayerTower.gd",
		"cost": 30,
		"description": "Penetrating shots that hit multiple enemies in a line"
	},
	"lightning_flower": {
		"name": "Lightning Flower",
		"script": "res://scripts/LightningFlowerTower.gd",
		"cost": 35,
		"description": "Chain lightning that jumps between nearby enemies"
	},
	# Legacy support
	"basic_shooter": {
		"name": "Basic Shooter",
		"script": "res://scripts/BasicShooterTower.gd",
		"cost": 25,
		"description": "A simple offensive tower that shoots projectiles"
	},
	"piercing_shooter": {
		"name": "Piercing Shooter",
		"script": "res://scripts/PiercingTower.gd",
		"cost": 35,
		"description": "Shoots piercing projectiles that can hit multiple enemies"
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

	# Set cursor to cross for tower placement
	Input.set_default_cursor_shape(Input.CURSOR_CROSS)

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

	# IMMEDIATELY position at mouse cursor
	update_placement_preview(get_global_mouse_position())

	print("Tower placement preview created in UI layer and positioned at mouse")

func create_range_preview():
	if not show_range_preview:
		return

	range_preview = Node2D.new()
	placement_preview.add_child(range_preview)

	# Get tower data for range
	var tower_data = available_towers[selected_tower_type]
	var preview_range = get_tower_range_preview(selected_tower_type)

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

	# Use the provided screen position or get current mouse position
	var mouse_pos = screen_pos if screen_pos != Vector2.ZERO else get_global_mouse_position()
	var td_scene = get_parent()
	var map_offset = td_scene.get_meta("map_offset", Vector2.ZERO)

	# Convert from screen coordinates to map coordinates
	var map_pos = mouse_pos - map_offset
	var grid_pos = snap_to_grid(map_pos)

	# Place preview at UI position (with map offset)
	var ui_pos = grid_pos + map_offset
	placement_preview.global_position = ui_pos
	
	print("Preview positioned at: mouse=%s, map=%s, grid=%s, ui=%s" % [mouse_pos, map_pos, grid_pos, ui_pos])

	# Check if position is valid and if we have enough honey
	var is_valid_position = is_valid_placement_position(grid_pos)
	var tower_data = available_towers[selected_tower_type]
	var tower_cost = tower_data["cost"]
	var current_honey = GameManager.get_resource("honey")
	var has_enough_honey = current_honey >= tower_cost

	var preview_visual = placement_preview.get_child(0)

	# Set color based on validity and honey availability
	if is_valid_position and has_enough_honey:
		preview_visual.color = Color.GREEN  # Can place
	elif is_valid_position and not has_enough_honey:
		preview_visual.color = Color.YELLOW  # Valid position but not enough honey
	else:
		preview_visual.color = Color.RED  # Invalid position

	print("Preview pos: UI=", ui_pos, " Map=", grid_pos, " Valid=", is_valid_position, " Honey=", current_honey, "/", tower_cost)

func snap_to_grid(pos: Vector2) -> Vector2:
	# Find which grid cell the mouse is in and snap to its center
	var grid_x = floor(pos.x / grid_size)
	var grid_y = floor(pos.y / grid_size)

	# Calculate center position of that grid cell
	var center_x = grid_x * grid_size + grid_size / 2
	var center_y = grid_y * grid_size + grid_size / 2

	return Vector2(center_x, center_y)

func is_valid_placement_position(pos: Vector2) -> bool:
	# Convert center-based position back to grid indices
	var grid_x = int(floor((pos.x - grid_size / 2) / grid_size))
	var grid_y = int(floor((pos.y - grid_size / 2) / grid_size))

	# Check bounds
	if grid_x < 0 or grid_x >= 20 or grid_y < 0 or grid_y >= 15:
		return false

	# Don't allow building on path tiles - need to check all path positions
	# Path includes: row 7 (cols 0-5), row 11 (cols 5-14), row 3 (cols 14-19),
	# col 5 (rows 7-11), col 14 (rows 3-11)
	if (grid_y == 7 and grid_x >= 0 and grid_x <= 5) or \
	   (grid_y == 11 and grid_x >= 5 and grid_x <= 14) or \
	   (grid_y == 3 and grid_x >= 14 and grid_x <= 19) or \
	   (grid_x == 5 and grid_y >= 7 and grid_y <= 11) or \
	   (grid_x == 14 and grid_y >= 3 and grid_y <= 11):
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
	var current_honey = GameManager.get_resource("honey")

	# Check if we still have enough honey
	if current_honey < cost:
		tower_placement_failed.emit("Not enough honey! Need " + str(cost) + " but only have " + str(current_honey))
		return

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

func get_tower_range_preview(tower_type: String) -> float:
	"""Get the range for preview based on tower type"""
	match tower_type:
		"stinger":
			return 80.0
		"propolis_bomber":
			return 100.0
		"nectar_sprayer":
			return 120.0
		"lightning_flower":
			return 90.0
		# Legacy support
		"basic_shooter":
			return 100.0
		"piercing_shooter":
			return 120.0
		_:
			return 100.0  # Default range

func cancel_placement():
	print("=== CANCELING TOWER PLACEMENT ===")
	print("Current mode: %s" % current_mode)
	print("Selected tower type: %s" % selected_tower_type)
	
	current_mode = PlacementMode.NONE
	selected_tower_type = ""
	
	# Aggressive cleanup
	cleanup_preview()
	
	# Wait for cleanup to complete
	await get_tree().process_frame
	
	# Force cleanup again
	force_cleanup_all_preview_objects()
	
	# Reset cursor to normal
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	placement_mode_changed.emit(false)
	
	# CRITICAL: Reset current_tower_type in TowerDefense
	var td_scene = get_parent()
	if td_scene.has_method("set_current_tower_type"):
		td_scene.set_current_tower_type("")
		print("Reset current_tower_type in TowerDefense")
	
	print("=== TOWER PLACEMENT CANCELED ===")

func cleanup_preview():
	print("=== CLEANING UP TOWER PLACEMENT PREVIEW ===")
	
	if placement_preview:
		print("Cleaning up placement_preview: %s" % placement_preview.name)
		if is_instance_valid(placement_preview):
			placement_preview.queue_free()
		placement_preview = null
	
	if range_preview:
		print("Cleaning up range_preview: %s" % range_preview.name)
		if is_instance_valid(range_preview):
			range_preview.queue_free()
		range_preview = null
	
	# Force cleanup of any remaining preview objects
	force_cleanup_all_preview_objects()
	
	print("=== TOWER PLACEMENT PREVIEW CLEANUP COMPLETE ===")

func force_cleanup_all_preview_objects():
	"""Force cleanup of ALL preview objects in the scene"""
	print("=== FORCE CLEANING UP ALL PREVIEW OBJECTS ===")
	
	# Get UI canvas
	var td_scene = get_parent()
	var ui_canvas = td_scene.get_node("UI")
	
	# Clean up ALL preview objects in UI canvas
	var preview_objects_to_remove = []
	for child in ui_canvas.get_children():
		var child_name = child.name
		if (child_name == "TowerPlacementPreview" or
			child_name.begins_with("TowerPlacementPreview") or
			child_name.begins_with("RangePreview") or
			"Preview" in child_name):
			print("Force cleaning preview object: %s" % child_name)
			preview_objects_to_remove.append(child)
	
	# Remove all identified preview objects
	for obj in preview_objects_to_remove:
		if is_instance_valid(obj):
			obj.queue_free()
	
	print("=== FORCE CLEANUP ALL PREVIEW OBJECTS COMPLETE ===")

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
