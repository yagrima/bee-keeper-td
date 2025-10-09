class_name TDDebug
extends RefCounted

# =============================================================================
# TOWER DEFENSE DEBUG UTILITIES
# =============================================================================
# Handles debug features and integration testing
# - Development mode detection
# - Debug overlay creation
# - Lightning Flower integration tests
# =============================================================================

var td_scene: Node2D
var is_development_build: bool = false
var debug_label: Label = null
const MAX_DEBUG_MESSAGES = 25

func _init(scene: Node2D):
	td_scene = scene

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
	
	return is_development_build

func create_debug_overlay():
	"""Create an in-game debug overlay to show keyboard events"""
	if not is_development_build:
		return null
	
	debug_label = Label.new()
	debug_label.position = Vector2(10, 10)
	debug_label.add_theme_font_size_override("font_size", 12)
	debug_label.add_theme_color_override("font_color", Color.YELLOW)
	debug_label.add_theme_color_override("font_outline_color", Color.BLACK)
	debug_label.add_theme_constant_override("outline_size", 2)
	debug_label.z_index = 1000  # On top of everything
	debug_label.text = "DEBUG: Press any key\n"
	td_scene.add_child(debug_label)
	print("✅ Debug overlay created")
	
	return debug_label

# =============================================================================
# INTEGRATION TEST FOR LIGHTNING FLOWER PLACEMENT & SELECTION
# =============================================================================

func run_lightning_flower_integration_test():
	"""Run integration test for Lightning Flower placement and selection"""
	print("\n" + "=".repeat(60))
	print("🧪 RUNNING LIGHTNING FLOWER INTEGRATION TEST")
	print("=".repeat(60))

	await td_scene.get_tree().process_frame  # Wait for scene to stabilize

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
	if td_scene.tower_placer and td_scene.tower_placer.current_mode != TowerPlacer.PlacementMode.NONE:
		td_scene.tower_placer.cancel_placement()

	# Start Lightning Flower placement
	td_scene._on_place_tower_pressed("lightning_flower")

	await td_scene.get_tree().process_frame

	# Place at a safe position
	var safe_position = Vector2(300, 300)
	if td_scene.tower_placer:
		td_scene.tower_placer.place_tower(safe_position)
		await td_scene.get_tree().process_frame

		# Check if tower was placed
		if td_scene.tower_placer.placed_towers.size() > 0:
			var last_tower = td_scene.tower_placer.placed_towers[-1]
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
	if td_scene.tower_placer.placed_towers.size() == 0:
		print("❌ FAILED: No towers to select")
		return false

	var tower = td_scene.tower_placer.placed_towers[-1]
	if tower and tower.tower_name == "Lightning Flower":
		# Simulate tower selection
		td_scene.tower_selection.select_tower(tower)
		await td_scene.get_tree().process_frame

		if td_scene.tower_selection.selected_tower == tower:
			print("✅ Lightning Flower selected successfully")
			return true
		else:
			print("❌ FAILED: Tower not selected")
	else:
		print("❌ FAILED: No Lightning Flower found")

	return false

func test_lightning_flower_range_indicator() -> bool:
	"""Test range indicator display"""
	if not td_scene.tower_selection.range_indicator:
		print("❌ FAILED: No range indicator found")
		return false

	if td_scene.tower_selection.range_indicator.get_parent():
		print("✅ Range indicator is in scene tree")
		return true
	else:
		print("❌ FAILED: Range indicator not in scene tree")
		return false
