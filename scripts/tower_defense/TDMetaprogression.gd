class_name TDMetaprogression
extends Node

# Reference to the main TowerDefense scene
var td_scene: Node2D

# Metaprogression state
var metaprogression_towers: Array[Tower] = []  # Towers in metaprogression fields
var picked_up_tower: Tower = null  # Currently picked up tower

func _init(td_scene_ref: Node2D):
	"""Initialize with reference to TowerDefense scene"""
	td_scene = td_scene_ref

# =============================================================================
# METAPROGRESSION FIELD SETUP
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

	var map_offset = td_scene.get_meta("map_offset", Vector2.ZERO)

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
	td_scene.get_node("UI").add_child(field_background)

	# Create border for the field
	create_field_border(field_background, world_pos)

	# Don't create field label - keeping fields clean
	# create_field_label(field_background, world_pos, field_number)

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
	var map_offset = td_scene.get_meta("map_offset", Vector2.ZERO)

	for i in range(5):
		# Get random tower type
		var random_tower_type = tower_types[randi() % tower_types.size()]

		# Calculate field position
		var field_x = start_x + (i * field_spacing)
		var field_pos = Vector2(field_x, row_y)
		var world_pos = Vector2(field_pos.x * 32, field_pos.y * 32) + map_offset

		# Center the tower in the 2x2 field (64x64 pixels)
		# Add 32 pixels to center it in the field
		var centered_tower_pos = world_pos + Vector2(32, 32)

		# Create tower in field (centered)
		var tower = create_metaprogression_tower(random_tower_type, centered_tower_pos, i + 1)
		if tower:
			metaprogression_towers.append(tower)
			print("Field %d: Assigned %s tower at centered position %s" % [i + 1, random_tower_type, centered_tower_pos])

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
	var ui_canvas = td_scene.get_node("UI")
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
	print("\n┌─ handle_metaprogression_tower_pickup ─────────────────────────")
	print("│ Click position: %s" % click_position)
	print("│ picked_up_tower: %s" % (picked_up_tower.tower_name if picked_up_tower else "null"))
	print("│ metaprogression_towers count: %d" % metaprogression_towers.size())

	# Check if we're already holding a tower
	if picked_up_tower != null:
		print("│ ➤ Already holding a tower, trying to place it...")
		var result = try_place_picked_up_tower(click_position)
		print("│ ➤ Placement result: %s" % result)
		print("└────────────────────────────────────────────────────────────────")
		return result

	# Check for metaprogression towers at click position
	print("│ Checking %d metaprogression towers:" % metaprogression_towers.size())
	var tower_index = 0
	for tower in metaprogression_towers:
		if tower and is_instance_valid(tower):
			var distance = click_position.distance_to(tower.global_position)
			print("│   [%d] %s at %s, distance: %.2f" % [tower_index, tower.tower_name, tower.global_position, distance])
			if distance < 32:  # Within tower radius
				print("│ ✅ Tower clicked! Picking up...")
				pickup_metaprogression_tower(tower)
				print("└────────────────────────────────────────────────────────────────")
				return true
		else:
			print("│   [%d] INVALID TOWER" % tower_index)
		tower_index += 1

	print("│ ❌ No tower found at click position")
	print("└────────────────────────────────────────────────────────────────")
	return false

func pickup_metaprogression_tower(tower: Tower):
	"""Pick up a metaprogression tower"""
	print("=== PICKING UP METAPROGRESSION TOWER ===")
	print("Tower name: %s" % tower.tower_name)
	print("Tower original position: %s" % tower.global_position)
	print("Mouse position: %s" % td_scene.get_global_mouse_position())

	# Store the original tower as the picked up tower
	picked_up_tower = tower

	# Store original position and parent for potential return
	picked_up_tower.set_meta("original_position", tower.global_position)
	picked_up_tower.set_meta("original_parent", tower.get_parent())
	picked_up_tower.set_meta("original_field_number", tower.get_meta("field_number", -1))

	# CRITICAL: Temporarily remove from metaprogression_towers to allow placement
	# It will be re-added if placement fails, or permanently removed if successful
	metaprogression_towers.erase(picked_up_tower)
	print("Tower temporarily removed from metaprogression_towers (count: %d)" % metaprogression_towers.size())

	# Move tower to follow mouse (keep it visible)
	picked_up_tower.z_index = 100  # Above everything

	# Show range indicator at mouse position
	td_scene.show_tower_range_at_mouse_position(picked_up_tower)

	# Create a visual indicator that we're holding a tower
	create_pickup_indicator(picked_up_tower)

	# Start following mouse position
	td_scene.start_tower_following_mouse()

	print("Stored original position: %s" % tower.global_position)
	print("Metaprogression tower picked up: %s" % picked_up_tower.tower_name)
	print("=== PICKUP COMPLETE ===")

func try_place_picked_up_tower(click_position: Vector2) -> bool:
	"""Try to place the picked up tower at the click position"""
	print("\n┌─ try_place_picked_up_tower ────────────────────────────────────")

	if picked_up_tower == null:
		print("│ ❌ ERROR: No tower to place!")
		print("└────────────────────────────────────────────────────────────────")
		return false

	print("│ Tower to place: %s" % picked_up_tower.tower_name)
	print("│ Click position (UI): %s" % click_position)

	# Get map offset for coordinate conversion
	var map_offset = td_scene.get_meta("map_offset", Vector2.ZERO)
	print("│ Map offset: %s" % map_offset)

	# Convert click position (UI coordinates) to map coordinates
	var map_position = click_position - map_offset
	print("│ Map position: %s" % map_position)

	# Calculate grid position for reference
	var grid_pos = Vector2(int(map_position.x / 32), int(map_position.y / 32))
	print("│ Grid position: %s" % grid_pos)

	# Check if position is valid for tower placement (using map coordinates)
	print("│ ➤ Calling is_valid_tower_placement_position...")
	var is_valid = is_valid_tower_placement_position(map_position)
	print("│ ➤ Validation result: %s" % is_valid)

	if is_valid:
		print("│ ✅ Position is valid, placing tower")
		place_picked_up_tower(click_position)
		print("└────────────────────────────────────────────────────────────────")
		return true
	else:
		print("│ ❌ Position is invalid, returning tower")
		return_picked_up_tower()
		print("└────────────────────────────────────────────────────────────────")
		return false

func is_valid_tower_placement_position(position: Vector2) -> bool:
	"""Check if position is valid for tower placement (position in map coordinates)"""
	print("\n  ┌─ is_valid_tower_placement_position ─────────────────────────")
	print("  │ Position (map): %s" % position)

	# Check if position is within the play area (20x15 grid)
	var grid_pos = Vector2(int(position.x / 32), int(position.y / 32))
	print("  │ Grid position: %s" % grid_pos)

	# Play area is 20x15 (0-19 x 0-14)
	if grid_pos.x < 0 or grid_pos.x >= 20 or grid_pos.y < 0 or grid_pos.y >= 15:
		print("  │ ❌ Position outside play area!")
		print("  └──────────────────────────────────────────────────────────────")
		return false
	print("  │ ✓ Position within play area")

	# Check if position is not on the path
	if is_position_on_path(position):
		print("  │ ❌ Position on path!")
		print("  └──────────────────────────────────────────────────────────────")
		return false
	print("  │ ✓ Position not on path")

	# Check if position is not occupied by another tower
	if is_position_occupied(position):
		print("  │ ❌ Position occupied!")
		print("  └──────────────────────────────────────────────────────────────")
		return false
	print("  │ ✓ Position not occupied")

	print("  │ ✅ All checks passed - position is valid!")
	print("  └──────────────────────────────────────────────────────────────")
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
	"""Check if position is occupied by another tower (position in map coordinates)"""
	print("Checking if position %s is occupied..." % position)

	# Grid-align the position for consistent checking
	var grid_pos = Vector2(int(position.x / 32), int(position.y / 32))
	var aligned_position = Vector2(grid_pos.x * 32 + 16, grid_pos.y * 32 + 16)
	print("  Aligned position: %s (grid: %s)" % [aligned_position, grid_pos])

	# Check tower placer towers (these are in map coordinates without offset)
	var tower_placer = td_scene.tower_placer
	if tower_placer and tower_placer.placed_towers:
		for tower in tower_placer.placed_towers:
			if tower and is_instance_valid(tower):
				# Use global_position for proper comparison
				var distance = aligned_position.distance_to(tower.global_position)
				print("  Tower at %s, distance: %.2f" % [tower.global_position, distance])
				if distance < 20:  # Within tower radius (reduced for grid cell)
					print("  ❌ Position occupied by placed tower!")
					return true

	# Check metaprogression towers (these are in UI coordinates with offset)
	var map_offset = td_scene.get_meta("map_offset", Vector2.ZERO)
	for tower in metaprogression_towers:
		if tower and is_instance_valid(tower):
			# Convert metaprogression tower position to map coordinates
			var tower_map_pos = tower.global_position - map_offset
			var distance = aligned_position.distance_to(tower_map_pos)
			print("  Metaprogression tower at %s (map: %s), distance: %.2f" % [tower.global_position, tower_map_pos, distance])
			if distance < 20:  # Within tower radius (reduced for grid cell)
				print("  ❌ Position occupied by metaprogression tower!")
				return true

	print("  ✅ Position is not occupied")
	return false

func place_picked_up_tower(position: Vector2):
	"""Place the picked up tower at the specified position (position in UI coordinates)"""
	print("=== PLACING PICKED UP TOWER ===")
	print("Click position (UI): %s" % position)

	if picked_up_tower == null:
		print("ERROR: No tower to place!")
		return

	# Get map offset for coordinate conversion
	var map_offset = td_scene.get_meta("map_offset", Vector2.ZERO)

	# Convert click position (UI coordinates) to map coordinates
	var map_position = position - map_offset

	# Align to grid (32x32 tiles) and center in grid cell
	var grid_pos = Vector2(int(map_position.x / 32), int(map_position.y / 32))
	var aligned_map_position = Vector2(grid_pos.x * 32 + 16, grid_pos.y * 32 + 16)  # Center in grid cell

	print("Map position: %s, Grid: %s, Aligned map: %s" % [map_position, grid_pos, aligned_map_position])

	# Get current parent
	var current_parent = picked_up_tower.get_parent()
	var ui_canvas = td_scene.get_node("UI")

	# Move tower to UI canvas (same as hotkey towers)
	if current_parent and current_parent != ui_canvas:
		current_parent.remove_child(picked_up_tower)
		print("Removed tower from parent: %s" % current_parent.name)

	# Add to UI canvas if not already there
	if picked_up_tower.get_parent() != ui_canvas:
		ui_canvas.add_child(picked_up_tower)
		print("Added tower to UI canvas")
	else:
		print("Tower already in UI canvas")

	# Reset z_index for proper placement
	picked_up_tower.z_index = 0

	# Set tower position to aligned map position + offset (UI coordinates)
	var aligned_ui_position = aligned_map_position + map_offset
	picked_up_tower.global_position = aligned_ui_position
	print("Aligned UI position: %s" % aligned_ui_position)

	# Make tower visible
	picked_up_tower.visible = true

	print("Tower positioned at: %s" % picked_up_tower.global_position)
	print("Tower parent: %s" % picked_up_tower.get_parent().name)
	print("Tower visible: %s" % picked_up_tower.visible)

	# Remove metaprogression tower metadata
	picked_up_tower.remove_meta("is_metaprogression_tower")
	picked_up_tower.remove_meta("field_number")
	picked_up_tower.remove_meta("original_position")
	picked_up_tower.remove_meta("original_parent")
	picked_up_tower.remove_meta("original_field_number")

	# Add to tower placer
	var tower_placer = td_scene.tower_placer
	if tower_placer:
		tower_placer.placed_towers.append(picked_up_tower)
		print("Tower added to tower_placer.placed_towers (count: %d)" % tower_placer.placed_towers.size())
	else:
		print("WARNING: tower_placer is null!")

	# Tower was already removed from metaprogression_towers during pickup
	# Just confirm it's not in the list
	if picked_up_tower in metaprogression_towers:
		metaprogression_towers.erase(picked_up_tower)
		print("WARNING: Tower was still in metaprogression_towers, removed it")
	print("Tower placement confirmed, metaprogression_towers count: %d" % metaprogression_towers.size())

	# Clear picked up tower
	picked_up_tower = null

	# Stop mouse following and remove indicators
	td_scene.stop_tower_following_mouse()
	remove_pickup_indicator()
	td_scene.clear_range_indicator()

	print("=== METAPROGRESSION TOWER PLACED SUCCESSFULLY ===")

func return_picked_up_tower():
	"""Return the picked up tower to its original position"""
	print("=== RETURNING PICKED UP TOWER TO ORIGINAL POSITION ===")

	if picked_up_tower == null:
		print("ERROR: No tower to return!")
		return

	# Get original position and parent from metadata
	var original_position = picked_up_tower.get_meta("original_position", Vector2.ZERO)
	var original_parent = picked_up_tower.get_meta("original_parent", null)
	var original_field_number = picked_up_tower.get_meta("original_field_number", -1)

	print("Original position: %s" % original_position)
	print("Original parent: %s" % (original_parent.name if original_parent else "null"))
	print("Original field number: %d" % original_field_number)

	# Restore original parent if needed
	if original_parent and picked_up_tower.get_parent() != original_parent:
		var current_parent = picked_up_tower.get_parent()
		if current_parent:
			current_parent.remove_child(picked_up_tower)
		original_parent.add_child(picked_up_tower)
		print("Restored tower to original parent: %s" % original_parent.name)

	# Restore original position
	picked_up_tower.global_position = original_position

	# Reset z_index
	picked_up_tower.z_index = 0

	# Make tower visible again
	picked_up_tower.visible = true

	# Restore metaprogression metadata
	picked_up_tower.set_meta("is_metaprogression_tower", true)
	picked_up_tower.set_meta("field_number", original_field_number)

	# Ensure tower is still in metaprogression_towers array
	if not picked_up_tower in metaprogression_towers:
		metaprogression_towers.append(picked_up_tower)
		print("Re-added tower to metaprogression_towers")

	print("Tower returned to position: %s" % picked_up_tower.global_position)

	# Clear picked up tower
	picked_up_tower = null

	# Stop mouse following and remove indicators
	td_scene.stop_tower_following_mouse()
	remove_pickup_indicator()
	td_scene.clear_range_indicator()

	print("=== TOWER RETURNED SUCCESSFULLY ===")

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

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func get_metaprogression_towers() -> Array:
	"""Get all metaprogression towers for placement validation"""
	return metaprogression_towers

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