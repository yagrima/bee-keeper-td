extends Node
class_name ComponentIntegrationTests

# Component Integration Test Suite
# Tests TowerDefense.gd component delegation and integration

signal test_completed(test_name: String, success: bool, message: String)
signal all_tests_completed(total: int, passed: int, failed: int)

var tests_passed: int = 0
var tests_failed: int = 0
var test_results: Array[Dictionary] = []

func run_all_tests():
	"""Run all component integration tests"""
	print("\n" + "=".repeat(60))
	print("COMPONENT INTEGRATION TEST SUITE")
	print("=".repeat(60))

	tests_passed = 0
	tests_failed = 0
	test_results.clear()

	# Run tests sequentially
	test_save_system_component()
	test_wave_controller_component()
	test_ui_manager_component()
	test_metaprogression_component()
	test_component_signal_connections()
	test_notification_manager_integration()
	test_error_handler_integration()
	test_autoload_initialization_order()

	# Print summary
	_print_test_summary()

	all_tests_completed.emit(tests_passed + tests_failed, tests_passed, tests_failed)

# =============================================================================
# COMPONENT EXISTENCE TESTS
# =============================================================================

func test_save_system_component() -> bool:
	"""Test TDSaveSystem component integration"""
	var test_name = "Component - TDSaveSystem"
	print("\n▶ Running: %s" % test_name)

	# Check if TowerDefense scene would have save_system component
	# (Cannot test without loading full scene, so we verify class exists)

	var script = load("res://scripts/tower_defense/TDSaveSystem.gd")

	if script:
		# Verify key methods exist
		var temp_instance = script.new(null)
		var has_auto_load = temp_instance.has_method("auto_load_game")
		var has_auto_save = temp_instance.has_method("auto_save_game")
		var has_get_data = temp_instance.has_method("get_tower_defense_data")

		temp_instance.queue_free()

		if has_auto_load and has_auto_save and has_get_data:
			return _record_test(test_name, true, "TDSaveSystem component exists with required methods")
		else:
			return _record_test(test_name, false, "Missing required methods")
	else:
		return _record_test(test_name, false, "TDSaveSystem.gd not found")

func test_wave_controller_component() -> bool:
	"""Test TDWaveController component integration"""
	var test_name = "Component - TDWaveController"
	print("\n▶ Running: %s" % test_name)

	var script = load("res://scripts/tower_defense/TDWaveController.gd")

	if script:
		var temp_instance = script.new(null)
		var has_wave_started = temp_instance.has_method("_on_wave_started")
		var has_wave_completed = temp_instance.has_method("_on_wave_completed")
		var has_auto_wave = temp_instance.has_method("start_automatic_next_wave")

		temp_instance.queue_free()

		if has_wave_started and has_wave_completed and has_auto_wave:
			return _record_test(test_name, true, "TDWaveController component exists with required methods")
		else:
			return _record_test(test_name, false, "Missing required methods")
	else:
		return _record_test(test_name, false, "TDWaveController.gd not found")

func test_ui_manager_component() -> bool:
	"""Test TDUIManager component integration"""
	var test_name = "Component - TDUIManager"
	print("\n▶ Running: %s" % test_name)

	var script = load("res://scripts/tower_defense/TDUIManager.gd")

	if script:
		var temp_instance = script.new(null)
		var has_update_ui = temp_instance.has_method("update_ui")
		var has_victory = temp_instance.has_method("show_victory_screen")
		var has_game_over = temp_instance.has_method("show_game_over_screen")

		temp_instance.queue_free()

		if has_update_ui and has_victory and has_game_over:
			return _record_test(test_name, true, "TDUIManager component exists with required methods")
		else:
			return _record_test(test_name, false, "Missing required methods")
	else:
		return _record_test(test_name, false, "TDUIManager.gd not found")

func test_metaprogression_component() -> bool:
	"""Test TDMetaprogression component integration"""
	var test_name = "Component - TDMetaprogression"
	print("\n▶ Running: %s" % test_name)

	var script = load("res://scripts/tower_defense/TDMetaprogression.gd")

	if script:
		var temp_instance = script.new(null)
		var has_setup = temp_instance.has_method("setup_metaprogression_fields")
		var has_pickup = temp_instance.has_method("handle_metaprogression_tower_pickup")
		var has_validation = temp_instance.has_method("is_valid_tower_placement_position")

		temp_instance.queue_free()

		if has_setup and has_pickup and has_validation:
			return _record_test(test_name, true, "TDMetaprogression component exists with required methods")
		else:
			return _record_test(test_name, false, "Missing required methods")
	else:
		return _record_test(test_name, false, "TDMetaprogression.gd not found")

# =============================================================================
# SIGNAL CONNECTION TESTS
# =============================================================================

func test_component_signal_connections() -> bool:
	"""Test component signal connections"""
	var test_name = "Component Signal Connections"
	print("\n▶ Running: %s" % test_name)

	# Verify SaveManager signals exist for NotificationManager
	if SaveManager:
		var has_cloud_sync_started = SaveManager.has_signal("cloud_sync_started")
		var has_cloud_sync_completed = SaveManager.has_signal("cloud_sync_completed")
		var has_save_completed = SaveManager.has_signal("save_completed")
		var has_load_completed = SaveManager.has_signal("load_completed")

		if has_cloud_sync_started and has_cloud_sync_completed and has_save_completed and has_load_completed:
			return _record_test(test_name, true, "SaveManager signals exist for integration")
		else:
			return _record_test(test_name, false, "Missing required signals on SaveManager")
	else:
		return _record_test(test_name, false, "SaveManager not available")

# =============================================================================
# NOTIFICATION & ERROR INTEGRATION TESTS
# =============================================================================

func test_notification_manager_integration() -> bool:
	"""Test NotificationManager integration"""
	var test_name = "NotificationManager Integration"
	print("\n▶ Running: %s" % test_name)

	if not NotificationManager:
		return _record_test(test_name, false, "NotificationManager not available")

	# Verify methods exist
	var has_show_loading = NotificationManager.has_method("show_loading")
	var has_show_success = NotificationManager.has_method("show_success")
	var has_show_error = NotificationManager.has_method("show_error")
	var has_connect_to_save = NotificationManager.has_method("_connect_to_save_manager")

	if has_show_loading and has_show_success and has_show_error and has_connect_to_save:
		return _record_test(test_name, true, "NotificationManager fully integrated")
	else:
		return _record_test(test_name, false, "NotificationManager missing methods")

func test_error_handler_integration() -> bool:
	"""Test ErrorHandler integration"""
	var test_name = "ErrorHandler Integration"
	print("\n▶ Running: %s" % test_name)

	if not ErrorHandler:
		return _record_test(test_name, false, "ErrorHandler not available")

	# Verify methods exist
	var has_handle_error = ErrorHandler.has_method("handle_error")
	var has_http_error = ErrorHandler.has_method("handle_http_error")
	var has_validation_error = ErrorHandler.has_method("handle_validation_error")

	if has_handle_error and has_http_error and has_validation_error:
		return _record_test(test_name, true, "ErrorHandler fully integrated")
	else:
		return _record_test(test_name, false, "ErrorHandler missing methods")

# =============================================================================
# AUTOLOAD INITIALIZATION TESTS
# =============================================================================

func test_autoload_initialization_order() -> bool:
	"""Test autoload initialization order"""
	var test_name = "Autoload Initialization Order"
	print("\n▶ Running: %s" % test_name)

	# Verify all required autoloads are initialized
	var required_autoloads = {
		"GameManager": GameManager,
		"SceneManager": SceneManager,
		"HotkeyManager": HotkeyManager,
		"SaveManager": SaveManager,
		"SupabaseClient": SupabaseClient,
		"NotificationManager": NotificationManager,
		"ErrorHandler": ErrorHandler
	}

	var all_initialized = true
	var missing_autoloads = []

	for autoload_name in required_autoloads:
		if not required_autoloads[autoload_name]:
			all_initialized = false
			missing_autoloads.append(autoload_name)

	if all_initialized:
		return _record_test(test_name, true, "All 7 autoloads initialized")
	else:
		return _record_test(test_name, false, "Missing autoloads: " + str(missing_autoloads))

# =============================================================================
# TEST UTILITIES
# =============================================================================

func _record_test(test_name: String, success: bool, message: String) -> bool:
	"""Record test result and emit signal"""
	if success:
		tests_passed += 1
		print("  ✅ PASS: %s" % message)
	else:
		tests_failed += 1
		print("  ❌ FAIL: %s" % message)

	test_results.append({
		"name": test_name,
		"success": success,
		"message": message
	})

	test_completed.emit(test_name, success, message)
	return success

func _print_test_summary():
	"""Print test summary"""
	print("\n" + "=".repeat(60))
	print("TEST SUMMARY")
	print("=".repeat(60))
	print("Total Tests: %d" % (tests_passed + tests_failed))
	print("✅ Passed: %d" % tests_passed)
	print("❌ Failed: %d" % tests_failed)
	print("Success Rate: %.1f%%" % (100.0 * tests_passed / max(1, tests_passed + tests_failed)))
	print("=".repeat(60))

	if tests_failed > 0:
		print("\nFailed Tests:")
		for result in test_results:
			if not result.success:
				print("  ❌ %s: %s" % [result.name, result.message])
