extends Node

# =============================================================================
# VECTOR TYPE COMPATIBILITY TESTS
# =============================================================================

func run_vector_type_tests():
	"""Run tests to ensure Vector2/Vector2i compatibility"""
	print("\n" + "=".repeat(60))
	print("🧪 RUNNING VECTOR TYPE COMPATIBILITY TESTS")
	print("=".repeat(60))
	
	var test_results = []
	
	# Test 1: Vector2 arithmetic operations
	test_results.append(test_vector2_arithmetic())
	
	# Test 2: get_visible_rect().size conversion
	test_results.append(test_viewport_size_conversion())
	
	# Test 3: Vector2 operations with mixed types
	test_results.append(test_mixed_vector_operations())
	
	# Test 4: Window centering calculations
	test_results.append(test_window_centering())
	
	# Test 5: Grid position calculations
	test_results.append(test_grid_calculations())
	
	# Print results
	print_test_results(test_results)
	
	return all_tests_passed(test_results)

func test_vector2_arithmetic() -> bool:
	"""Test basic Vector2 arithmetic operations"""
	print("Test 1: Vector2 arithmetic operations...")
	
	try:
		var v1 = Vector2(100, 200)
		var v2 = Vector2(50, 75)
		
		# Test addition
		var sum = v1 + v2
		assert(sum == Vector2(150, 275), "Vector2 addition failed")
		
		# Test subtraction
		var diff = v1 - v2
		assert(diff == Vector2(50, 125), "Vector2 subtraction failed")
		
		# Test multiplication
		var mult = v1 * 2.0
		assert(mult == Vector2(200, 400), "Vector2 multiplication failed")
		
		# Test division
		var div = v1 / 2.0
		assert(div == Vector2(50, 100), "Vector2 division failed")
		
		print("✅ Vector2 arithmetic operations passed")
		return true
	except:
		print("❌ Vector2 arithmetic operations failed")
		return false

func test_viewport_size_conversion() -> bool:
	"""Test conversion of get_visible_rect().size to Vector2"""
	print("Test 2: Viewport size conversion...")
	
	try:
		# Simulate get_visible_rect().size returning Vector2i
		var viewport_size_i = Vector2i(1920, 1080)
		
		# Convert to Vector2
		var viewport_size = Vector2(viewport_size_i)
		assert(viewport_size == Vector2(1920, 1080), "Vector2i to Vector2 conversion failed")
		
		# Test arithmetic with converted Vector2
		var map_size = Vector2(640, 480)
		var center_offset = (viewport_size - map_size) / 2
		var expected = Vector2(640, 300)
		assert(center_offset == expected, "Viewport size arithmetic failed")
		
		print("✅ Viewport size conversion passed")
		return true
	except:
		print("❌ Viewport size conversion failed")
		return false

func test_mixed_vector_operations() -> bool:
	"""Test operations between Vector2 and Vector2i"""
	print("Test 3: Mixed vector operations...")
	
	try:
		var v2 = Vector2(100, 200)
		var v2i = Vector2i(50, 75)
		
		# Test Vector2 + Vector2i (should work)
		var sum = v2 + Vector2(v2i)
		assert(sum == Vector2(150, 275), "Vector2 + Vector2i failed")
		
		# Test Vector2 - Vector2i (should work)
		var diff = v2 - Vector2(v2i)
		assert(diff == Vector2(50, 125), "Vector2 - Vector2i failed")
		
		# Test multiplication with float
		var mult = v2 * 1.5
		assert(mult == Vector2(150, 300), "Vector2 * float failed")
		
		print("✅ Mixed vector operations passed")
		return true
	except:
		print("❌ Mixed vector operations failed")
		return false

func test_window_centering() -> bool:
	"""Test window centering calculations"""
	print("Test 4: Window centering calculations...")
	
	try:
		# Simulate window size (Vector2i from get_visible_rect().size)
		var window_size_i = Vector2i(1920, 1080)
		var window_size = Vector2(window_size_i)
		
		# Test dialog centering
		var dialog_size = Vector2(400, 300)
		var dialog_position = (window_size - dialog_size) / 2
		var expected = Vector2(760, 390)
		assert(dialog_position == expected, "Dialog centering failed")
		
		# Test panel centering
		var panel_size = Vector2(600, 400)
		var panel_position = (window_size - panel_size) / 2
		var expected_panel = Vector2(660, 340)
		assert(panel_position == expected_panel, "Panel centering failed")
		
		print("✅ Window centering calculations passed")
		return true
	except:
		print("❌ Window centering calculations failed")
		return false

func test_grid_calculations() -> bool:
	"""Test grid position calculations"""
	print("Test 5: Grid calculations...")
	
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
		
		print("✅ Grid calculations passed")
		return true
	except:
		print("❌ Grid calculations failed")
		return false

func print_test_results(results: Array[bool]):
	"""Print test results summary"""
	var passed = 0
	var total = results.size()
	
	for result in results:
		if result:
			passed += 1
	
	print("\n" + "=".repeat(60))
	print("📊 VECTOR TYPE TEST RESULTS")
	print("=".repeat(60))
	print("Tests Passed: %d/%d" % [passed, total])
	print("Success Rate: %.1f%%" % [(float(passed) / float(total)) * 100.0])
	
	if passed == total:
		print("✅ ALL VECTOR TYPE TESTS PASSED")
	else:
		print("❌ SOME VECTOR TYPE TESTS FAILED")
	
	print("=".repeat(60))

func all_tests_passed(results: Array[bool]) -> bool:
	"""Check if all tests passed"""
	for result in results:
		if not result:
			return false
	return true

# =============================================================================
# QUICK TEST FUNCTIONS
# =============================================================================

func quick_vector_test():
	"""Quick test for common vector operations"""
	print("🔍 Quick Vector Test:")
	
	# Test 1: Basic operations
	var v1 = Vector2(100, 200)
	var v2 = Vector2(50, 75)
	var result = v1 - v2
	print("  Vector2 subtraction: %s - %s = %s" % [v1, v2, result])
	
	# Test 2: Viewport size simulation
	var viewport_size = Vector2(Vector2i(1920, 1080))
	var map_size = Vector2(640, 480)
	var center = (viewport_size - map_size) / 2
	print("  Window centering: %s - %s = %s" % [viewport_size, map_size, center])
	
	# Test 3: Grid calculations
	var grid = Vector2(5, 3)
	var world = grid * 32
	print("  Grid to world: %s * 32 = %s" % [grid, world])
	
	print("✅ Quick vector test completed")

func test_vector_compatibility():
	"""Test Vector2/Vector2i compatibility issues"""
	print("🔍 Testing Vector2/Vector2i compatibility...")
	
	# Test the specific error case
	try:
		var v2 = Vector2(100, 200)
		var v2i = Vector2i(50, 75)
		
		# This should work now with explicit conversion
		var result = v2 - Vector2(v2i)
		print("  Vector2 - Vector2i: %s - %s = %s" % [v2, v2i, result])
		
		# Test the reverse
		var result2 = Vector2(v2i) - v2
		print("  Vector2i - Vector2: %s - %s = %s" % [v2i, v2, result2])
		
		print("✅ Vector compatibility test passed")
		return true
	except Exception as e:
		print("❌ Vector compatibility test failed: %s" % str(e))
		return false
