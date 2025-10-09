class_name TDTowerSelection
extends RefCounted

# =============================================================================
# TOWER DEFENSE TOWER SELECTION
# =============================================================================
# Handles tower selection and range indicator display
# - Click detection on towers
# - Tower selection state
# - Range indicator creation and display
# - Range indicator cleanup
# =============================================================================

var td_scene: Node2D
var selected_tower: Tower = null
var range_indicator: Node2D = null
var is_placing_tower: bool = false

func _init(scene: Node2D):
	td_scene = scene

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
	if not td_scene.tower_placer:
		print("No tower placer found")
		return null

	print("=== TOWER DETECTION ===")
	print("Checking ", td_scene.tower_placer.placed_towers.size(), " towers for click at ", position)

	var closest_tower: Tower = null
	var closest_distance: float = 999999.0

	for i in range(td_scene.tower_placer.placed_towers.size()):
		var tower = td_scene.tower_placer.placed_towers[i]
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
	await td_scene.get_tree().process_frame

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
	var ui_canvas = td_scene.get_node("UI")
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
	var ui_canvas = td_scene.get_node_or_null("UI")
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
	var ui_canvas = td_scene.get_node("UI")
	ui_canvas.add_child(range_indicator)

func update_mouse_position(mouse_pos: Vector2):
	"""Update range indicator position for mouse following"""
	if range_indicator:
		range_indicator.global_position = mouse_pos

func on_tower_placed():
	"""Called when a tower is placed to prevent immediate selection"""
	is_placing_tower = true

func on_tower_placement_complete():
	"""Called after tower placement is complete to allow selection again"""
	is_placing_tower = false
	print("Tower placement complete, selection enabled again")
