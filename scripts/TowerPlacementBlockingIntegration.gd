extends Node

# Tower Placement Blocking Integration
# Provides easy access to tower placement blocking tests

var blocking_test = null
var is_test_running = false

func _ready():
	print("=== TOWER PLACEMENT BLOCKING INTEGRATION READY ===")
	
	# Auto-start test in development mode
	if OS.is_debug_build() or OS.has_feature("debug"):
		start_blocking_test()

func start_blocking_test():
	"""Start the tower placement blocking test"""
	if is_test_running:
		print("⚠️ Tower placement blocking test already running")
		return false
	
	print("🏗️ Starting Tower Placement Blocking Test...")
	
	# Create the test instance
	blocking_test = preload("res://scripts/TowerPlacementBlockingTest.gd").new()
	blocking_test.name = "TowerPlacementBlockingTest"
	add_child(blocking_test)
	
	# Start the test
	var success = blocking_test.start_test()
	if success:
		is_test_running = true
		print("✅ Tower placement blocking test started successfully")
		
		# Print test summary every 30 seconds
		start_test_summary_timer()
	else:
		print("❌ Failed to start tower placement blocking test")
		blocking_test.queue_free()
		blocking_test = null
	
	return success

func stop_blocking_test():
	"""Stop the tower placement blocking test"""
	if not is_test_running:
		print("⚠️ No tower placement blocking test running")
		return false
	
	print("🛑 Stopping Tower Placement Blocking Test...")
	
	if blocking_test:
		blocking_test.stop_test()
		blocking_test.cleanup_test()
		blocking_test.queue_free()
		blocking_test = null
	
	is_test_running = false
	print("✅ Tower placement blocking test stopped")
	return true

func start_test_summary_timer():
	"""Start a timer to print test summaries"""
	var timer = Timer.new()
	timer.name = "TestSummaryTimer"
	timer.wait_time = 30.0  # Print summary every 30 seconds
	timer.timeout.connect(_on_test_summary_timer_timeout)
	add_child(timer)
	timer.start()

func _on_test_summary_timer_timeout():
	"""Print test summary every 30 seconds"""
	if blocking_test and is_test_running:
		blocking_test.print_test_summary()

func get_test_status() -> Dictionary:
	"""Get current test status"""
	if not blocking_test:
		return {
			"status": "Not running",
			"is_running": false,
			"test_count": 0,
			"success_rate": 0.0
		}
	
	var summary = blocking_test.get_test_summary()
	return {
		"status": summary.status,
		"is_running": is_test_running,
		"test_count": summary.total_tests,
		"success_rate": summary.success_rate,
		"last_result": summary.last_result
	}

func print_test_status():
	"""Print current test status"""
	var status = get_test_status()
	print("=== TOWER PLACEMENT BLOCKING TEST STATUS ===")
	print("Status: %s" % status.status)
	print("Running: %s" % status.is_running)
	print("Test Count: %d" % status.test_count)
	print("Success Rate: %.1f%%" % status.success_rate)
	
	if status.last_result:
		var last = status.last_result
		print("Last Test Results:")
		print("  Occupied Test: %s" % ("✅ PASS" if last.occupied_test else "❌ FAIL"))
		print("  Metaprogression Test: %s" % ("✅ PASS" if last.metaprogression_test else "❌ FAIL"))
		print("  Cross-System Test: %s" % ("✅ PASS" if last.cross_system_test else "❌ FAIL"))
		print("  Boundary Test: %s" % ("✅ PASS" if last.boundary_test else "❌ FAIL"))
		print("  Overall: %s" % ("✅ PASS" if last.all_passed else "❌ FAIL"))

func force_test_now():
	"""Force an immediate test run"""
	if blocking_test and is_test_running:
		blocking_test.force_test_now()
		print("🧪 Forced immediate test run")
	else:
		print("⚠️ No test running to force")

func toggle_test():
	"""Toggle the test on/off"""
	if is_test_running:
		stop_blocking_test()
	else:
		start_blocking_test()

func cleanup():
	"""Clean up all test resources"""
	print("🧹 Cleaning up tower placement blocking test...")
	
	if blocking_test:
		blocking_test.cleanup_test()
		blocking_test.queue_free()
		blocking_test = null
	
	# Clean up timer
	var timer = get_node_or_null("TestSummaryTimer")
	if timer:
		timer.queue_free()
	
	is_test_running = false
	print("✅ Cleanup complete")

func _exit_tree():
	"""Clean up when node is removed"""
	cleanup()
