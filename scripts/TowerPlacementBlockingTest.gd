extends Node

# Tower Placement Blocking Test
# Continuously monitors that no towers can be placed on occupied grid positions

var test_name = "Tower Placement Blocking Test"
var is_running = false
var test_results = []
var tower_defense_scene = null
var tower_placer = null

# Test configuration
var test_interval = 1.0  # Test every second
var test_timer = null

# Tracked positions for validation
var occupied_positions = []
var metaprogression_positions = []

func _ready():
	print("=== TOWER PLACEMENT BLOCKING TEST INITIALIZED ===")
	setup_test_timer()

func setup_test_timer():
	"""Setup timer for continuous testing"""
	test_timer = Timer.new()
	test_timer.wait_time = test_interval
	test_timer.timeout.connect(_on_test_timer_timeout)
	add_child(test_timer)
	print("Test timer setup complete - testing every %.1f seconds" % test_interval)

func start_test():
	"""Start the continuous tower placement blocking test"""
	print("=== STARTING TOWER PLACEMENT BLOCKING TEST ===")
	
	# Find TowerDefense scene
	tower_defense_scene = get_tree().get_first_node_in_group("tower_defense")
	if not tower_defense_scene:
		print("ERROR: TowerDefense scene not found!")
		return false
	
	# Get tower placer
	tower_placer = tower_defense_scene.get_node("TowerPlacer")
	if not tower_placer:
		print("ERROR: TowerPlacer not found!")
		return false
	
	is_running = true
	test_timer.start()
	print("Tower placement blocking test started")
	return true

func stop_test():
	"""Stop the continuous test"""
	print("=== STOPPING TOWER PLACEMENT BLOCKING TEST ===")
	is_running = false
	if test_timer:
		test_timer.stop()
	print("Tower placement blocking test stopped")

func _on_test_timer_timeout():
	"""Called every test interval to validate tower placement blocking"""
	if not is_running:
		return
	
	print("=== RUNNING TOWER PLACEMENT BLOCKING VALIDATION ===")
	
	# Test 1: Validate occupied positions
	var occupied_test_passed = test_occupied_positions()
	
	# Test 2: Validate metaprogression positions
	var metaprogression_test_passed = test_metaprogression_positions()
	
	# Test 3: Validate cross-system blocking
	var cross_system_test_passed = test_cross_system_blocking()
	
	# Test 4: Validate grid boundary behavior
	var boundary_test_passed = test_grid_boundary_behavior()
	
	# Record results
	var all_tests_passed = occupied_test_passed and metaprogression_test_passed and cross_system_test_passed and boundary_test_passed
	
	if all_tests_passed:
		print("✅ All tower placement blocking tests PASSED")
	else:
		print("❌ Some tower placement blocking tests FAILED")
	
	# Store result
	var result = {
		"timestamp": Time.get_unix_time_from_system(),
		"occupied_test": occupied_test_passed,
		"metaprogression_test": metaprogression_test_passed,
		"cross_system_test": cross_system_test_passed,
		"boundary_test": boundary_test_passed,
		"all_passed": all_tests_passed
	}
	
	test_results.append(result)
	
	# Keep only last 100 results
	if test_results.size() > 100:
		test_results.pop_front()

func test_occupied_positions() -> bool:
	"""Test that occupied positions are properly blocked"""
	print("Testing occupied positions...")
	
	if not tower_placer or not tower_placer.placed_towers:
		print("No placed towers to test")
		return true
	
	var test_passed = true
	var occupied_positions = []
	
	# Collect all occupied positions
	for tower in tower_placer.placed_towers:
		if tower and is_instance_valid(tower):
			var pos = tower.global_position
			occupied_positions.append(pos)
			print("Found occupied position: %s" % pos)
	
	# Test each occupied position
	for pos in occupied_positions:
		var is_valid = tower_placer.is_valid_placement_position(pos)
		if is_valid:
			print("❌ ERROR: Position %s is occupied but validation returned true!" % pos)
			test_passed = false
		else:
			print("✅ Position %s correctly blocked" % pos)
	
	return test_passed

func test_metaprogression_positions() -> bool:
	"""Test that metaprogression tower positions are properly blocked"""
	print("Testing metaprogression positions...")
	
	if not tower_defense_scene or not tower_defense_scene.has_method("get_metaprogression_towers"):
		print("No metaprogression towers to test")
		return true
	
	var metaprogression_towers = tower_defense_scene.get_metaprogression_towers()
	if not metaprogression_towers:
		print("No metaprogression towers to test")
		return true
	
	var test_passed = true
	var metaprogression_positions = []
	
	# Collect all metaprogression positions
	for tower in metaprogression_towers:
		if tower and is_instance_valid(tower):
			var pos = tower.global_position
			metaprogression_positions.append(pos)
			print("Found metaprogression position: %s" % pos)
	
	# Test each metaprogression position
	for pos in metaprogression_positions:
		var is_valid = tower_placer.is_valid_placement_position(pos)
		if is_valid:
			print("❌ ERROR: Metaprogression position %s is occupied but validation returned true!" % pos)
			test_passed = false
		else:
			print("✅ Metaprogression position %s correctly blocked" % pos)
	
	return test_passed

func test_cross_system_blocking() -> bool:
	"""Test that cross-system blocking works (hotkey vs metaprogression)"""
	print("Testing cross-system blocking...")
	
	if not tower_defense_scene or not tower_placer:
		print("Required scenes not available")
		return true
	
	var test_passed = true
	
	# Test 1: Hotkey placement blocking metaprogression
	if tower_defense_scene.has_method("get_metaprogression_towers"):
		var metaprogression_towers = tower_defense_scene.get_metaprogression_towers()
		for tower in metaprogression_towers:
			if tower and is_instance_valid(tower):
				var pos = tower.global_position
				var is_valid = tower_placer.is_valid_placement_position(pos)
				if is_valid:
					print("❌ ERROR: Cross-system blocking failed - metaprogression position %s not blocked for hotkey placement!" % pos)
					test_passed = false
				else:
					print("✅ Cross-system blocking works - metaprogression position %s blocked for hotkey placement" % pos)
	
	# Test 2: Metaprogression placement blocking hotkey
	if tower_placer.placed_towers:
		for tower in tower_placer.placed_towers:
			if tower and is_instance_valid(tower):
				var pos = tower.global_position
				var is_valid = tower_defense_scene.is_valid_tower_placement_position(pos)
				if is_valid:
					print("❌ ERROR: Cross-system blocking failed - hotkey position %s not blocked for metaprogression placement!" % pos)
					test_passed = false
				else:
					print("✅ Cross-system blocking works - hotkey position %s blocked for metaprogression placement" % pos)
	
	return test_passed

func test_grid_boundary_behavior() -> bool:
	"""Test that grid boundary behavior is correct"""
	print("Testing grid boundary behavior...")
	
	var test_passed = true
	
	# Test valid positions (should be allowed)
	var valid_positions = [
		Vector2(0, 0),    # Top-left corner
		Vector2(19, 0),   # Top-right corner
		Vector2(0, 14),   # Bottom-left corner
		Vector2(19, 14),  # Bottom-right corner
		Vector2(10, 7)    # Center position
	]
	
	for pos in valid_positions:
		var is_valid = tower_placer.is_valid_placement_position(pos)
		if not is_valid:
			print("❌ ERROR: Valid position %s incorrectly blocked!" % pos)
			test_passed = false
		else:
			print("✅ Valid position %s correctly allowed" % pos)
	
	# Test invalid positions (should be blocked)
	var invalid_positions = [
		Vector2(-1, 0),   # Left of grid
		Vector2(20, 0),   # Right of grid
		Vector2(0, -1),   # Above grid
		Vector2(0, 15),   # Below grid
		Vector2(5, 7),    # On path
		Vector2(14, 3)    # On path
	]
	
	for pos in invalid_positions:
		var is_valid = tower_placer.is_valid_placement_position(pos)
		if is_valid:
			print("❌ ERROR: Invalid position %s incorrectly allowed!" % pos)
			test_passed = false
		else:
			print("✅ Invalid position %s correctly blocked" % pos)
	
	return test_passed

func get_test_summary() -> Dictionary:
	"""Get summary of test results"""
	if test_results.is_empty():
		return {"status": "No tests run", "total_tests": 0, "passed_tests": 0}
	
	var total_tests = test_results.size()
	var passed_tests = 0
	
	for result in test_results:
		if result.get("all_passed", false):
			passed_tests += 1
	
	var success_rate = float(passed_tests) / float(total_tests) * 100.0
	
	return {
		"status": "Running" if is_running else "Stopped",
		"total_tests": total_tests,
		"passed_tests": passed_tests,
		"failed_tests": total_tests - passed_tests,
		"success_rate": success_rate,
		"last_result": test_results[-1] if not test_results.is_empty() else null
	}

func print_test_summary():
	"""Print current test summary"""
	var summary = get_test_summary()
	print("=== TOWER PLACEMENT BLOCKING TEST SUMMARY ===")
	print("Status: %s" % summary.status)
	print("Total Tests: %d" % summary.total_tests)
	print("Passed Tests: %d" % summary.passed_tests)
	print("Failed Tests: %d" % summary.failed_tests)
	print("Success Rate: %.1f%%" % summary.success_rate)
	
	if summary.last_result:
		var last = summary.last_result
		print("Last Test Results:")
		print("  Occupied Test: %s" % ("✅ PASS" if last.occupied_test else "❌ FAIL"))
		print("  Metaprogression Test: %s" % ("✅ PASS" if last.metaprogression_test else "❌ FAIL"))
		print("  Cross-System Test: %s" % ("✅ PASS" if last.cross_system_test else "❌ FAIL"))
		print("  Boundary Test: %s" % ("✅ PASS" if last.boundary_test else "❌ FAIL"))
		print("  Overall: %s" % ("✅ PASS" if last.all_passed else "❌ FAIL"))

func force_test_now():
	"""Force a test run immediately"""
	print("=== FORCING IMMEDIATE TEST ===")
	_on_test_timer_timeout()

func cleanup_test():
	"""Clean up test resources"""
	print("=== CLEANING UP TOWER PLACEMENT BLOCKING TEST ===")
	stop_test()
	
	if test_timer:
		test_timer.queue_free()
		test_timer = null
	
	test_results.clear()
	print("Test cleanup complete")
