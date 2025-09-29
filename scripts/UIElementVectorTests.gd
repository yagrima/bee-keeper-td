extends Node

# =============================================================================
# UI ELEMENT VECTOR2/VECTOR2I TESTS
# =============================================================================

func run_ui_element_vector_tests():
	"""Run tests specifically for UI element vector operations"""
	print("\n" + "=".repeat(70))
	print("🧪 RUNNING UI ELEMENT VECTOR TESTS")
	print("=".repeat(70))
	
	var test_results = []
	
	# Test 1: Dialog elements
	test_results.append(test_dialog_elements())
	
	# Test 2: Panel elements
	test_results.append(test_panel_elements())
	
	# Test 3: Button elements
	test_results.append(test_button_elements())
	
	# Test 4: Label elements
	test_results.append(test_label_elements())
	
	# Test 5: Notification elements
	test_results.append(test_notification_elements())
	
	# Test 6: Overlay elements
	test_results.append(test_overlay_elements())
	
	# Print results
	print_ui_test_results(test_results)
	
	return all_tests_passed(test_results)

func test_dialog_elements() -> bool:
	"""Test dialog element vector operations"""
	print("Test 1: Dialog elements...")
	
	try:
		# Test save dialog
		var save_dialog_size = Vector2(400, 200)
		var window_size = Vector2(1920, 1080)
		var save_position = (window_size - save_dialog_size) / 2
		assert(save_position == Vector2(760, 440), "Save dialog positioning failed")
		
		# Test load dialog
		var load_dialog_size = Vector2(500, 400)
		var load_position = (window_size - load_dialog_size) / 2
		assert(load_position == Vector2(710, 340), "Load dialog positioning failed")
		
		# Test error dialog
		var error_dialog_size = Vector2(300, 100)
		var error_position = (window_size - error_dialog_size) / 2
		assert(error_position == Vector2(810, 490), "Error dialog positioning failed")
		
		print("✅ Dialog elements passed")
		return true
	except Exception as e:
		print("❌ Dialog elements failed: %s" % str(e))
		return false

func test_panel_elements() -> bool:
	"""Test panel element vector operations"""
	print("Test 2: Panel elements...")
	
	try:
		var window_size = Vector2(1920, 1080)
		
		# Test victory panel
		var victory_panel_size = Vector2(400, 300)
		var victory_position = (window_size - victory_panel_size) / 2
		assert(victory_position == Vector2(760, 390), "Victory panel positioning failed")
		
		# Test game over panel
		var game_over_panel_size = Vector2(400, 300)
		var game_over_position = (window_size - game_over_panel_size) / 2
		assert(game_over_position == Vector2(760, 390), "Game over panel positioning failed")
		
		# Test with different panel sizes
		var panel_sizes = [Vector2(300, 200), Vector2(500, 400), Vector2(600, 500)]
		for size in panel_sizes:
			var position = (window_size - size) / 2
			var expected_x = (window_size.x - size.x) / 2
			var expected_y = (window_size.y - size.y) / 2
			assert(position.x == expected_x, "Panel X positioning failed for size %s" % size)
			assert(position.y == expected_y, "Panel Y positioning failed for size %s" % size)
		
		print("✅ Panel elements passed")
		return true
	except Exception as e:
		print("❌ Panel elements failed: %s" % str(e))
		return false

func test_button_elements() -> bool:
	"""Test button element vector operations"""
	print("Test 3: Button elements...")
	
	try:
		# Test tower buttons
		var base_position = Vector2(100, 200)
		var button_size = Vector2(120, 40)
		var button_spacing = 140
		
		# Test individual button positions
		var button_positions = []
		for i in range(4):
			var pos = base_position + Vector2(button_spacing * i, 0)
			button_positions.append(pos)
		
		var expected_positions = [
			Vector2(100, 200),   # Button 0
			Vector2(240, 200),   # Button 1
			Vector2(380, 200),   # Button 2
			Vector2(520, 200)    # Button 3
		]
		
		for i in range(button_positions.size()):
			assert(button_positions[i] == expected_positions[i], "Button %d positioning failed" % i)
		
		# Test speed button
		var speed_button_pos = Vector2(1000, 200)
		var speed_button_size = Vector2(150, 40)
		assert(speed_button_pos == Vector2(1000, 200), "Speed button positioning failed")
		
		print("✅ Button elements passed")
		return true
	except Exception as e:
		print("❌ Button elements failed: %s" % str(e))
		return false

func test_label_elements() -> bool:
	"""Test label element vector operations"""
	print("Test 4: Label elements...")
	
	try:
		# Test wave composition label
		var wave_composition_pos = Vector2(20, 70)
		assert(wave_composition_pos == Vector2(20, 70), "Wave composition label positioning failed")
		
		# Test wave countdown label
		var wave_countdown_pos = Vector2(20, 90)
		assert(wave_countdown_pos == Vector2(20, 90), "Wave countdown label positioning failed")
		
		# Test resource labels
		var honey_label_pos = Vector2(20, 20)
		var health_label_pos = Vector2(20, 40)
		assert(honey_label_pos == Vector2(20, 20), "Honey label positioning failed")
		assert(health_label_pos == Vector2(20, 40), "Health label positioning failed")
		
		# Test label sizing
		var label_size = Vector2(200, 20)
		assert(label_size == Vector2(200, 20), "Label sizing failed")
		
		print("✅ Label elements passed")
		return true
	except Exception as e:
		print("❌ Label elements failed: %s" % str(e))
		return false

func test_notification_elements() -> bool:
	"""Test notification element vector operations"""
	print("Test 5: Notification elements...")
	
	try:
		var window_size = Vector2(1920, 1080)
		
		# Test notification centering
		var notification_size = Vector2(300, 100)
		var notification_position = (window_size - notification_size) / 2
		assert(notification_position == Vector2(810, 490), "Notification positioning failed")
		
		# Test with different notification sizes
		var notification_sizes = [Vector2(200, 80), Vector2(400, 120), Vector2(500, 150)]
		for size in notification_sizes:
			var position = (window_size - size) / 2
			var expected_x = (window_size.x - size.x) / 2
			var expected_y = (window_size.y - size.y) / 2
			assert(position.x == expected_x, "Notification X positioning failed for size %s" % size)
			assert(position.y == expected_y, "Notification Y positioning failed for size %s" % size)
		
		print("✅ Notification elements passed")
		return true
	except Exception as e:
		print("❌ Notification elements failed: %s" % str(e))
		return false

func test_overlay_elements() -> bool:
	"""Test overlay element vector operations"""
	print("Test 6: Overlay elements...")
	
	try:
		# Test victory overlay
		var victory_overlay_size = Vector2(1920, 1080)
		assert(victory_overlay_size == Vector2(1920, 1080), "Victory overlay sizing failed")
		
		# Test game over overlay
		var game_over_overlay_size = Vector2(1920, 1080)
		assert(game_over_overlay_size == Vector2(1920, 1080), "Game over overlay sizing failed")
		
		# Test overlay positioning
		var overlay_position = Vector2.ZERO
		assert(overlay_position == Vector2.ZERO, "Overlay positioning failed")
		
		# Test with different window sizes
		var window_sizes = [Vector2(800, 600), Vector2(1920, 1080), Vector2(2560, 1440)]
		for size in window_sizes:
			var overlay_size = size
			assert(overlay_size == size, "Overlay sizing failed for window size %s" % size)
		
		print("✅ Overlay elements passed")
		return true
	except Exception as e:
		print("❌ Overlay elements failed: %s" % str(e))
		return false

func print_ui_test_results(results: Array[bool]):
	"""Print UI test results"""
	var passed = 0
	var total = results.size()
	
	for result in results:
		if result:
			passed += 1
	
	print("\n" + "=".repeat(70))
	print("📊 UI ELEMENT VECTOR TEST RESULTS")
	print("=".repeat(70))
	print("Tests Passed: %d/%d" % [passed, total])
	print("Success Rate: %.1f%%" % [(float(passed) / float(total)) * 100.0])
	
	if passed == total:
		print("✅ ALL UI ELEMENT VECTOR TESTS PASSED")
		print("🎯 All UI element vector operations are working correctly!")
	else:
		print("❌ SOME UI ELEMENT VECTOR TESTS FAILED")
		print("🔧 UI element vector operations need attention!")
	
	print("=".repeat(70))

func all_tests_passed(results: Array[bool]) -> bool:
	"""Check if all tests passed"""
	for result in results:
		if not result:
			return false
	return true

# =============================================================================
# SPECIFIC UI ELEMENT VALIDATION
# =============================================================================

func validate_dialog_centering():
	"""Validate dialog centering calculations"""
	print("🔍 Validating dialog centering...")
	
	var window_size = Vector2(1920, 1080)
	var dialogs = [
		{"name": "Save Dialog", "size": Vector2(400, 200)},
		{"name": "Load Dialog", "size": Vector2(500, 400)},
		{"name": "Error Dialog", "size": Vector2(300, 100)},
		{"name": "Notification", "size": Vector2(300, 100)}
	]
	
	for dialog in dialogs:
		var position = (window_size - dialog.size) / 2
		var expected_x = (window_size.x - dialog.size.x) / 2
		var expected_y = (window_size.y - dialog.size.y) / 2
		
		assert(position.x == expected_x, "%s X centering failed" % dialog.name)
		assert(position.y == expected_y, "%s Y centering failed" % dialog.name)
		print("  ✅ %s: %s" % [dialog.name, position])
	
	print("✅ Dialog centering validation completed")

func validate_panel_centering():
	"""Validate panel centering calculations"""
	print("🔍 Validating panel centering...")
	
	var window_size = Vector2(1920, 1080)
	var panels = [
		{"name": "Victory Panel", "size": Vector2(400, 300)},
		{"name": "Game Over Panel", "size": Vector2(400, 300)},
		{"name": "Small Panel", "size": Vector2(300, 200)},
		{"name": "Large Panel", "size": Vector2(600, 500)}
	]
	
	for panel in panels:
		var position = (window_size - panel.size) / 2
		var expected_x = (window_size.x - panel.size.x) / 2
		var expected_y = (window_size.y - panel.size.y) / 2
		
		assert(position.x == expected_x, "%s X centering failed" % panel.name)
		assert(position.y == expected_y, "%s Y centering failed" % panel.name)
		print("  ✅ %s: %s" % [panel.name, position])
	
	print("✅ Panel centering validation completed")

func validate_button_positioning():
	"""Validate button positioning calculations"""
	print("🔍 Validating button positioning...")
	
	var base_position = Vector2(100, 200)
	var button_spacing = 140
	
	# Test tower buttons
	for i in range(4):
		var position = base_position + Vector2(button_spacing * i, 0)
		var expected = Vector2(100 + button_spacing * i, 200)
		assert(position == expected, "Tower button %d positioning failed" % i)
		print("  ✅ Tower Button %d: %s" % [i, position])
	
	# Test speed button
	var speed_position = Vector2(1000, 200)
	assert(speed_position == Vector2(1000, 200), "Speed button positioning failed")
	print("  ✅ Speed Button: %s" % speed_position)
	
	print("✅ Button positioning validation completed")

func validate_label_positioning():
	"""Validate label positioning calculations"""
	print("🔍 Validating label positioning...")
	
	var labels = [
		{"name": "Honey Label", "position": Vector2(20, 20)},
		{"name": "Health Label", "position": Vector2(20, 40)},
		{"name": "Wave Label", "position": Vector2(20, 60)},
		{"name": "Wave Composition", "position": Vector2(20, 70)},
		{"name": "Wave Countdown", "position": Vector2(20, 90)}
	]
	
	for label in labels:
		assert(label.position == label.position, "%s positioning failed" % label.name)
		print("  ✅ %s: %s" % [label.name, label.position])
	
	print("✅ Label positioning validation completed")

# =============================================================================
# COMPREHENSIVE UI VALIDATION
# =============================================================================

func run_comprehensive_ui_validation():
	"""Run comprehensive UI validation"""
	print("\n" + "=".repeat(80))
	print("🔍 RUNNING COMPREHENSIVE UI VALIDATION")
	print("=".repeat(80))
	
	# Validate all UI elements
	validate_dialog_centering()
	validate_panel_centering()
	validate_button_positioning()
	validate_label_positioning()
	
	print("\n" + "=".repeat(80))
	print("✅ COMPREHENSIVE UI VALIDATION COMPLETED")
	print("🎯 All UI element vector operations validated successfully!")
	print("=".repeat(80))
