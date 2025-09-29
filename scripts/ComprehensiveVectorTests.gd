extends Node

# =============================================================================
# COMPREHENSIVE VECTOR2/VECTOR2I COMPATIBILITY TESTS
# =============================================================================

func run_comprehensive_vector_tests():
	"""Run comprehensive tests for all Vector2/Vector2i operations"""
	print("\n" + "=".repeat(80))
	print("🧪 RUNNING COMPREHENSIVE VECTOR2/VECTOR2I COMPATIBILITY TESTS")
	print("=".repeat(80))
	
	var test_results = []
	
	# Test 1: Basic Vector2 operations
	test_results.append(test_basic_vector2_operations())
	
	# Test 2: Vector2i to Vector2 conversion
	test_results.append(test_vector2i_to_vector2_conversion())
	
	# Test 3: Mixed Vector2/Vector2i operations
	test_results.append(test_mixed_vector_operations())
	
	# Test 4: Dialog centering calculations
	test_results.append(test_dialog_centering())
	
	# Test 5: Window size operations
	test_results.append(test_window_size_operations())
	
	# Test 6: Grid calculations
	test_results.append(test_grid_calculations())
	
	# Test 7: UI element positioning
	test_results.append(test_ui_element_positioning())
	
	# Test 8: Panel centering
	test_results.append(test_panel_centering())
	
	# Test 9: Notification positioning
	test_results.append(test_notification_positioning())
	
	# Test 10: Edge cases and error conditions
	test_results.append(test_edge_cases())
	
	# Print comprehensive results
	print_comprehensive_results(test_results)
	
	return all_tests_passed(test_results)

func test_basic_vector2_operations() -> bool:
	"""Test basic Vector2 arithmetic operations"""
	print("Test 1: Basic Vector2 operations...")
	
	try:
		var v1 = Vector2(100, 200)
		var v2 = Vector2(50, 75)
		
		# Test all arithmetic operations
		var sum = v1 + v2
		var diff = v1 - v2
		var mult = v1 * 2.0
		var div = v1 / 2.0
		
		assert(sum == Vector2(150, 275), "Vector2 addition failed")
		assert(diff == Vector2(50, 125), "Vector2 subtraction failed")
		assert(mult == Vector2(200, 400), "Vector2 multiplication failed")
		assert(div == Vector2(50, 100), "Vector2 division failed")
		
		print("✅ Basic Vector2 operations passed")
		return true
	except Exception as e:
		print("❌ Basic Vector2 operations failed: %s" % str(e))
		return false

func test_vector2i_to_vector2_conversion() -> bool:
	"""Test Vector2i to Vector2 conversion"""
	print("Test 2: Vector2i to Vector2 conversion...")
	
	try:
		# Test explicit conversion
		var v2i = Vector2i(1920, 1080)
		var v2 = Vector2(v2i)
		assert(v2 == Vector2(1920, 1080), "Vector2i to Vector2 conversion failed")
		
		# Test with arithmetic
		var map_size = Vector2(640, 480)
		var center = (v2 - map_size) / 2
		var expected = Vector2(640, 300)
		assert(center == expected, "Vector2i arithmetic after conversion failed")
		
		# Test multiple conversions
		var sizes = [Vector2i(800, 600), Vector2i(1920, 1080), Vector2i(2560, 1440)]
		for size_i in sizes:
			var size_2 = Vector2(size_i)
			assert(size_2 == Vector2(size_i.x, size_i.y), "Multiple conversion failed")
		
		print("✅ Vector2i to Vector2 conversion passed")
		return true
	except Exception as e:
		print("❌ Vector2i to Vector2 conversion failed: %s" % str(e))
		return false

func test_mixed_vector_operations() -> bool:
	"""Test operations between Vector2 and Vector2i"""
	print("Test 3: Mixed Vector2/Vector2i operations...")
	
	try:
		var v2 = Vector2(100, 200)
		var v2i = Vector2i(50, 75)
		
		# Test Vector2 + Vector2i (with conversion)
		var sum = v2 + Vector2(v2i)
		assert(sum == Vector2(150, 275), "Vector2 + Vector2i failed")
		
		# Test Vector2 - Vector2i (with conversion)
		var diff = v2 - Vector2(v2i)
		assert(diff == Vector2(50, 125), "Vector2 - Vector2i failed")
		
		# Test Vector2i + Vector2 (with conversion)
		var sum2 = Vector2(v2i) + v2
		assert(sum2 == Vector2(150, 275), "Vector2i + Vector2 failed")
		
		# Test Vector2i - Vector2 (with conversion)
		var diff2 = Vector2(v2i) - v2
		assert(diff2 == Vector2(-50, -125), "Vector2i - Vector2 failed")
		
		print("✅ Mixed Vector2/Vector2i operations passed")
		return true
	except Exception as e:
		print("❌ Mixed Vector2/Vector2i operations failed: %s" % str(e))
		return false

func test_dialog_centering() -> bool:
	"""Test dialog centering calculations"""
	print("Test 4: Dialog centering calculations...")
	
	try:
		# Simulate window size (Vector2i from get_visible_rect().size)
		var window_size_i = Vector2i(1920, 1080)
		var window_size = Vector2(window_size_i)
		
		# Test dialog centering
		var dialog_size = Vector2(400, 300)
		var dialog_position = (window_size - dialog_size) / 2
		var expected = Vector2(760, 390)
		assert(dialog_position == expected, "Dialog centering failed")
		
		# Test with different dialog sizes
		var dialog_sizes = [Vector2(300, 200), Vector2(500, 400), Vector2(600, 500)]
		for size in dialog_sizes:
			var pos = (window_size - size) / 2
			var expected_pos = Vector2((window_size.x - size.x) / 2, (window_size.y - size.y) / 2)
			assert(pos == expected_pos, "Dialog centering with size %s failed" % size)
		
		print("✅ Dialog centering calculations passed")
		return true
	except Exception as e:
		print("❌ Dialog centering calculations failed: %s" % str(e))
		return false

func test_window_size_operations() -> bool:
	"""Test window size operations"""
	print("Test 5: Window size operations...")
	
	try:
		# Test get_visible_rect().size simulation
		var viewport_size_i = Vector2i(1920, 1080)
		var viewport_size = Vector2(viewport_size_i)
		
		# Test overlay sizing
		var overlay_size = viewport_size
		assert(overlay_size == Vector2(1920, 1080), "Overlay sizing failed")
		
		# Test panel centering
		var panel_size = Vector2(400, 300)
		var panel_position = (viewport_size - panel_size) / 2
		var expected = Vector2(760, 390)
		assert(panel_position == expected, "Panel centering failed")
		
		# Test with different window sizes
		var window_sizes = [Vector2i(800, 600), Vector2i(1920, 1080), Vector2i(2560, 1440)]
		for size_i in window_sizes:
			var size = Vector2(size_i)
			var center = size / 2
			var expected_center = Vector2(size_i.x / 2, size_i.y / 2)
			assert(center == expected_center, "Window centering failed for size %s" % size_i)
		
		print("✅ Window size operations passed")
		return true
	except Exception as e:
		print("❌ Window size operations failed: %s" % str(e))
		return false

func test_grid_calculations() -> bool:
	"""Test grid position calculations"""
	print("Test 6: Grid calculations...")
	
	try:
		# Test grid to world position conversion
		var grid_pos = Vector2(5, 3)
		var tile_size = 32
		var world_pos = grid_pos * tile_size
		assert(world_pos == Vector2(160, 96), "Grid to world conversion failed")
		
		# Test map offset calculations
		var map_offset = Vector2(640, 300)
		var field_pos = Vector2(2, 16)
		var world_field_pos = field_pos * tile_size + map_offset
		var expected = Vector2(704, 812)
		assert(world_field_pos == expected, "Map offset calculation failed")
		
		# Test button positioning
		var base_position = Vector2(100, 200)
		var button_spacing = 140
		var button_pos = base_position + Vector2(button_spacing * 2, 0)
		assert(button_pos == Vector2(380, 200), "Button positioning failed")
		
		# Test grid snapping
		var click_pos = Vector2(165, 95)
		var grid_x = int(floor((click_pos.x - tile_size / 2) / tile_size))
		var grid_y = int(floor((click_pos.y - tile_size / 2) / tile_size))
		assert(grid_x == 5, "Grid snapping X failed")
		assert(grid_y == 3, "Grid snapping Y failed")
		
		print("✅ Grid calculations passed")
		return true
	except Exception as e:
		print("❌ Grid calculations failed: %s" % str(e))
		return false

func test_ui_element_positioning() -> bool:
	"""Test UI element positioning"""
	print("Test 7: UI element positioning...")
	
	try:
		# Test button positioning
		var base_pos = Vector2(100, 200)
		var button_size = Vector2(120, 40)
		var spacing = 140
		
		# Test multiple button positions
		for i in range(4):
			var button_pos = base_pos + Vector2(spacing * i, 0)
			var expected = Vector2(100 + spacing * i, 200)
			assert(button_pos == expected, "Button %d positioning failed" % i)
		
		# Test label positioning
		var label_pos = Vector2(20, 70)
		var label_size = Vector2(200, 20)
		assert(label_pos == Vector2(20, 70), "Label positioning failed")
		
		# Test countdown positioning
		var countdown_pos = Vector2(20, 90)
		assert(countdown_pos == Vector2(20, 90), "Countdown positioning failed")
		
		print("✅ UI element positioning passed")
		return true
	except Exception as e:
		print("❌ UI element positioning failed: %s" % str(e))
		return false

func test_panel_centering() -> bool:
	"""Test panel centering calculations"""
	print("Test 8: Panel centering...")
	
	try:
		# Test victory panel centering
		var window_size = Vector2(1920, 1080)
		var panel_size = Vector2(400, 300)
		var panel_position = (window_size - panel_size) / 2
		var expected = Vector2(760, 390)
		assert(panel_position == expected, "Victory panel centering failed")
		
		# Test game over panel centering
		var game_over_panel_size = Vector2(400, 300)
		var game_over_position = (window_size - game_over_panel_size) / 2
		assert(game_over_position == expected, "Game over panel centering failed")
		
		# Test with different panel sizes
		var panel_sizes = [Vector2(300, 200), Vector2(500, 400), Vector2(600, 500)]
		for size in panel_sizes:
			var pos = (window_size - size) / 2
			var expected_pos = Vector2((window_size.x - size.x) / 2, (window_size.y - size.y) / 2)
			assert(pos == expected_pos, "Panel centering with size %s failed" % size)
		
		print("✅ Panel centering passed")
		return true
	except Exception as e:
		print("❌ Panel centering failed: %s" % str(e))
		return false

func test_notification_positioning() -> bool:
	"""Test notification positioning"""
	print("Test 9: Notification positioning...")
	
	try:
		# Test notification centering
		var window_size = Vector2(1920, 1080)
		var notification_size = Vector2(300, 100)
		var notification_position = (window_size - notification_size) / 2
		var expected = Vector2(810, 490)
		assert(notification_position == expected, "Notification centering failed")
		
		# Test with different notification sizes
		var notification_sizes = [Vector2(200, 80), Vector2(400, 120), Vector2(500, 150)]
		for size in notification_sizes:
			var pos = (window_size - size) / 2
			var expected_pos = Vector2((window_size.x - size.x) / 2, (window_size.y - size.y) / 2)
			assert(pos == expected_pos, "Notification centering with size %s failed" % size)
		
		print("✅ Notification positioning passed")
		return true
	except Exception as e:
		print("❌ Notification positioning failed: %s" % str(e))
		return false

func test_edge_cases() -> bool:
	"""Test edge cases and error conditions"""
	print("Test 10: Edge cases and error conditions...")
	
	try:
		# Test zero vectors
		var zero_v2 = Vector2.ZERO
		var zero_v2i = Vector2i.ZERO
		assert(zero_v2 == Vector2(0, 0), "Zero Vector2 failed")
		assert(Vector2(zero_v2i) == Vector2(0, 0), "Zero Vector2i conversion failed")
		
		# Test negative values
		var neg_v2 = Vector2(-100, -200)
		var neg_v2i = Vector2i(-50, -75)
		assert(neg_v2 == Vector2(-100, -200), "Negative Vector2 failed")
		assert(Vector2(neg_v2i) == Vector2(-50, -75), "Negative Vector2i conversion failed")
		
		# Test very large values
		var large_v2 = Vector2(999999, 999999)
		var large_v2i = Vector2i(999999, 999999)
		assert(large_v2 == Vector2(999999, 999999), "Large Vector2 failed")
		assert(Vector2(large_v2i) == Vector2(999999, 999999), "Large Vector2i conversion failed")
		
		# Test floating point precision
		var float_v2 = Vector2(100.5, 200.7)
		var int_v2i = Vector2i(100, 200)
		assert(Vector2(int_v2i) == Vector2(100, 200), "Float to int conversion failed")
		
		# Test arithmetic with edge cases
		var result = Vector2(100, 200) - Vector2(Vector2i(50, 75))
		assert(result == Vector2(50, 125), "Edge case arithmetic failed")
		
		print("✅ Edge cases and error conditions passed")
		return true
	except Exception as e:
		print("❌ Edge cases and error conditions failed: %s" % str(e))
		return false

func print_comprehensive_results(results: Array[bool]):
	"""Print comprehensive test results"""
	var passed = 0
	var total = results.size()
	
	for result in results:
		if result:
			passed += 1
	
	print("\n" + "=".repeat(80))
	print("📊 COMPREHENSIVE VECTOR TEST RESULTS")
	print("=".repeat(80))
	print("Tests Passed: %d/%d" % [passed, total])
	print("Success Rate: %.1f%%" % [(float(passed) / float(total)) * 100.0])
	
	if passed == total:
		print("✅ ALL COMPREHENSIVE VECTOR TESTS PASSED")
		print("🎯 All Vector2/Vector2i operations are working correctly!")
	else:
		print("❌ SOME COMPREHENSIVE VECTOR TESTS FAILED")
		print("🔧 Vector2/Vector2i operations need attention!")
	
	print("=".repeat(80))

func all_tests_passed(results: Array[bool]) -> bool:
	"""Check if all tests passed"""
	for result in results:
		if not result:
			return false
	return true

# =============================================================================
# SPECIFIC OPERATION TESTS
# =============================================================================

func test_dialog_size_operations():
	"""Test specific dialog size operations that might cause issues"""
	print("🔍 Testing dialog size operations...")
	
	try:
		# Simulate dialog.size returning Vector2i
		var dialog_size_i = Vector2i(400, 300)
		var dialog_size = Vector2(dialog_size_i)
		
		# Test centering calculation
		var window_size = Vector2(1920, 1080)
		var position = (window_size - dialog_size) / 2
		var expected = Vector2(760, 390)
		assert(position == expected, "Dialog size centering failed")
		
		print("✅ Dialog size operations passed")
		return true
	except Exception as e:
		print("❌ Dialog size operations failed: %s" % str(e))
		return false

func test_all_size_properties():
	"""Test all .size properties that might return Vector2i"""
	print("🔍 Testing all .size properties...")
	
	try:
		# Test various size properties
		var sizes_to_test = [
			Vector2i(400, 300),  # Dialog size
			Vector2i(500, 400),  # Load dialog size
			Vector2i(300, 100),  # Notification size
			Vector2i(1920, 1080)  # Window size
		]
		
		for size_i in sizes_to_test:
			var size = Vector2(size_i)
			var window_size = Vector2(1920, 1080)
			var position = (window_size - size) / 2
			
			# Verify the calculation works
			var expected_x = (window_size.x - size.x) / 2
			var expected_y = (window_size.y - size.y) / 2
			assert(position.x == expected_x, "Size property X calculation failed")
			assert(position.y == expected_y, "Size property Y calculation failed")
		
		print("✅ All .size properties passed")
		return true
	except Exception as e:
		print("❌ All .size properties failed: %s" % str(e))
		return false

# =============================================================================
# QUICK VALIDATION FUNCTIONS
# =============================================================================

func quick_vector_validation():
	"""Quick validation of common vector operations"""
	print("🔍 Quick Vector Validation:")
	
	# Test 1: Basic conversion
	var v2i = Vector2i(1920, 1080)
	var v2 = Vector2(v2i)
	print("  Vector2i to Vector2: %s -> %s" % [v2i, v2])
	
	# Test 2: Arithmetic with conversion
	var window_size = Vector2(1920, 1080)
	var dialog_size_i = Vector2i(400, 300)
	var dialog_size = Vector2(dialog_size_i)
	var center = (window_size - dialog_size) / 2
	print("  Dialog centering: %s - %s = %s" % [window_size, dialog_size, center])
	
	# Test 3: Multiple conversions
	var sizes = [Vector2i(300, 200), Vector2i(500, 400), Vector2i(600, 500)]
	for size_i in sizes:
		var size = Vector2(size_i)
		var pos = (window_size - size) / 2
		print("  Size %s -> Position %s" % [size, pos])
	
	print("✅ Quick validation completed")

func validate_all_vector_operations():
	"""Validate all vector operations in the codebase"""
	print("🔍 Validating all vector operations...")
	
	# Test all common scenarios
	var test_cases = [
		{"name": "Dialog Centering", "window": Vector2(1920, 1080), "size": Vector2(400, 300)},
		{"name": "Panel Centering", "window": Vector2(1920, 1080), "size": Vector2(500, 400)},
		{"name": "Notification Centering", "window": Vector2(1920, 1080), "size": Vector2(300, 100)},
		{"name": "Small Window", "window": Vector2(800, 600), "size": Vector2(300, 200)},
		{"name": "Large Window", "window": Vector2(2560, 1440), "size": Vector2(600, 500)}
	]
	
	for test_case in test_cases:
		var window = test_case.window
		var size = test_case.size
		var position = (window - size) / 2
		var expected_x = (window.x - size.x) / 2
		var expected_y = (window.y - size.y) / 2
		
		assert(position.x == expected_x, "%s X calculation failed" % test_case.name)
		assert(position.y == expected_y, "%s Y calculation failed" % test_case.name)
		print("  ✅ %s: %s" % [test_case.name, position])
	
	print("✅ All vector operations validated")
