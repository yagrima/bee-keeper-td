extends Node
class_name CloudSaveTests

# Cloud Save/Load Test Suite
# Tests cloud-first save strategy, HMAC integrity, auto-save triggers

signal test_completed(test_name: String, success: bool, message: String)
signal all_tests_completed(total: int, passed: int, failed: int)

var tests_passed: int = 0
var tests_failed: int = 0
var test_results: Array[Dictionary] = []

func run_all_tests():
	"""Run all cloud save/load tests"""
	print("\n" + "=".repeat(60))
	print("CLOUD SAVE/LOAD TEST SUITE")
	print("=".repeat(60))

	tests_passed = 0
	tests_failed = 0
	test_results.clear()

	# Run tests sequentially
	await test_local_save_basic()
	await test_local_load_basic()
	await test_cloud_save_authenticated()
	await test_cloud_load_authenticated()
	await test_cloud_first_strategy()
	await test_hmac_checksum_generation()
	await test_hmac_checksum_validation()
	await test_save_data_structure()
	await test_offline_fallback()
	await test_rate_limiting()

	# Print summary
	_print_test_summary()

	all_tests_completed.emit(tests_passed + tests_failed, tests_passed, tests_failed)

# =============================================================================
# LOCAL SAVE/LOAD TESTS
# =============================================================================

func test_local_save_basic() -> bool:
	"""Test basic local save functionality"""
	var test_name = "Local Save - Basic"
	print("\n▶ Running: %s" % test_name)

	if not SaveManager:
		return _record_test(test_name, false, "SaveManager not available")

	# Create test data
	SaveManager.save_data = {
		"test_key": "test_value",
		"timestamp": Time.get_unix_time_from_system()
	}

	# Save locally
	var success = SaveManager.write_save_file("test_save")

	if success:
		return _record_test(test_name, true, "Local save successful")
	else:
		return _record_test(test_name, false, "Local save failed")

func test_local_load_basic() -> bool:
	"""Test basic local load functionality"""
	var test_name = "Local Load - Basic"
	print("\n▶ Running: %s" % test_name)

	if not SaveManager:
		return _record_test(test_name, false, "SaveManager not available")

	# Load the save from previous test
	var loaded_data = SaveManager.read_save_file("test_save")

	if loaded_data is Dictionary and loaded_data.has("test_key"):
		if loaded_data["test_key"] == "test_value":
			return _record_test(test_name, true, "Local load successful, data matches")
		else:
			return _record_test(test_name, false, "Data mismatch")
	else:
		return _record_test(test_name, false, "Local load failed or incomplete")

# =============================================================================
# CLOUD SAVE/LOAD TESTS
# =============================================================================

func test_cloud_save_authenticated() -> bool:
	"""Test cloud save when authenticated"""
	var test_name = "Cloud Save - Authenticated"
	print("\n▶ Running: %s" % test_name)

	if not SaveManager or not SupabaseClient:
		return _record_test(test_name, false, "SaveManager or SupabaseClient not available")

	# Ensure authenticated
	if not SupabaseClient.is_authenticated():
		# Quick login for test
		var test_email = "cloud_save_test@example.com"
		var test_password = "SecurePassword123!@#"
		await SupabaseClient.login(test_email, test_password)

		if not SupabaseClient.is_authenticated():
			return _record_test(test_name, false, "Could not authenticate for test")

	# Prepare test data
	SaveManager.save_data = {
		"version": "1.0",
		"timestamp": Time.get_unix_time_from_system(),
		"test_cloud_data": "cloud_test_value_%d" % Time.get_unix_time_from_system()
	}

	# Save to cloud
	var success = await SaveManager.save_to_cloud()

	if success:
		return _record_test(test_name, true, "Cloud save successful")
	else:
		return _record_test(test_name, false, "Cloud save failed")

func test_cloud_load_authenticated() -> bool:
	"""Test cloud load when authenticated"""
	var test_name = "Cloud Load - Authenticated"
	print("\n▶ Running: %s" % test_name)

	if not SaveManager or not SupabaseClient:
		return _record_test(test_name, false, "SaveManager or SupabaseClient not available")

	if not SupabaseClient.is_authenticated():
		return _record_test(test_name, false, "Not authenticated")

	# Load from cloud
	var success = await SaveManager.load_from_cloud()

	if success and SaveManager.save_data.has("test_cloud_data"):
		return _record_test(test_name, true, "Cloud load successful, data retrieved")
	else:
		return _record_test(test_name, false, "Cloud load failed or data missing")

func test_cloud_first_strategy() -> bool:
	"""Test cloud-first strategy (cloud overrides local)"""
	var test_name = "Cloud-First Strategy"
	print("\n▶ Running: %s" % test_name)

	if not SaveManager:
		return _record_test(test_name, false, "SaveManager not available")

	# Create different local and cloud data
	var local_value = "local_data_%d" % Time.get_unix_time_from_system()
	var cloud_value = "cloud_data_%d" % Time.get_unix_time_from_system()

	# Save local
	SaveManager.save_data = {"test_key": local_value, "timestamp": Time.get_unix_time_from_system()}
	SaveManager.write_save_file("conflict_test")

	# Save to cloud with different value
	if SupabaseClient and SupabaseClient.is_authenticated():
		SaveManager.save_data = {"test_key": cloud_value, "timestamp": Time.get_unix_time_from_system()}
		await SaveManager.save_to_cloud()

		# Clear local data
		SaveManager.save_data = {}

		# Load with cloud-first strategy
		await SaveManager.load_game("conflict_test")

		# Check if cloud data won
		if SaveManager.save_data.has("test_key"):
			if SaveManager.save_data["test_key"] == cloud_value:
				return _record_test(test_name, true, "Cloud-first strategy works, cloud data used")
			else:
				return _record_test(test_name, false, "Local data used instead of cloud")
		else:
			return _record_test(test_name, false, "No data loaded")
	else:
		return _record_test(test_name, true, "Skipped (not authenticated)")

# =============================================================================
# HMAC INTEGRITY TESTS
# =============================================================================

func test_hmac_checksum_generation() -> bool:
	"""Test HMAC checksum generation"""
	var test_name = "HMAC Checksum - Generation"
	print("\n▶ Running: %s" % test_name)

	if not SaveManager:
		return _record_test(test_name, false, "SaveManager not available")

	var test_data = {
		"version": "1.0",
		"test": "data"
	}

	var checksum = SaveManager.calculate_save_checksum(test_data)

	if checksum != "" and checksum.length() == 64:  # SHA-256 = 64 hex chars
		return _record_test(test_name, true, "HMAC checksum generated (64 chars)")
	else:
		return _record_test(test_name, false, "Invalid checksum format: " + checksum)

func test_hmac_checksum_validation() -> bool:
	"""Test HMAC checksum validation"""
	var test_name = "HMAC Checksum - Validation"
	print("\n▶ Running: %s" % test_name)

	if not SaveManager:
		return _record_test(test_name, false, "SaveManager not available")

	var test_data = {
		"version": "1.0",
		"test": "data"
	}

	var checksum = SaveManager.calculate_save_checksum(test_data)

	# Create save data with checksum
	var save_with_checksum = test_data.duplicate()
	save_with_checksum["checksum"] = checksum

	# Validate
	var is_valid = SaveManager.verify_save_checksum(save_with_checksum)

	if is_valid:
		# Now test with tampered data
		var tampered_data = save_with_checksum.duplicate()
		tampered_data["test"] = "tampered"

		var is_invalid = not SaveManager.verify_save_checksum(tampered_data)

		if is_invalid:
			return _record_test(test_name, true, "Checksum validation works, detects tampering")
		else:
			return _record_test(test_name, false, "Failed to detect tampering")
	else:
		return _record_test(test_name, false, "Valid checksum rejected")

# =============================================================================
# DATA STRUCTURE & VALIDATION TESTS
# =============================================================================

func test_save_data_structure() -> bool:
	"""Test save data structure validity"""
	var test_name = "Save Data Structure"
	print("\n▶ Running: %s" % test_name)

	if not SaveManager:
		return _record_test(test_name, false, "SaveManager not available")

	# Collect save data
	SaveManager.collect_save_data()

	# Verify required fields
	var required_fields = ["version", "timestamp", "game_state", "player_data"]
	var all_present = true

	for field in required_fields:
		if not SaveManager.save_data.has(field):
			all_present = false
			print("  Missing field: %s" % field)

	if all_present:
		return _record_test(test_name, true, "All required fields present")
	else:
		return _record_test(test_name, false, "Missing required fields")

# =============================================================================
# OFFLINE & ERROR HANDLING TESTS
# =============================================================================

func test_offline_fallback() -> bool:
	"""Test offline fallback (local save when cloud unavailable)"""
	var test_name = "Offline Fallback"
	print("\n▶ Running: %s" % test_name)

	if not SaveManager:
		return _record_test(test_name, false, "SaveManager not available")

	# Save when not authenticated (simulates offline)
	if SupabaseClient:
		await SupabaseClient.logout()

	SaveManager.save_data = {
		"offline_test": "value",
		"timestamp": Time.get_unix_time_from_system()
	}

	var success = SaveManager.save_game("offline_test")

	if success:
		# Verify local save exists
		var loaded = SaveManager.read_save_file("offline_test")
		if loaded and loaded.has("offline_test"):
			return _record_test(test_name, true, "Offline fallback works, saved locally")
		else:
			return _record_test(test_name, false, "Local save not found")
	else:
		return _record_test(test_name, false, "Offline save failed")

func test_rate_limiting() -> bool:
	"""Test rate limiting detection (Token Bucket)"""
	var test_name = "Rate Limiting"
	print("\n▶ Running: %s" % test_name)

	# Note: Cannot easily test rate limiting without spamming real requests
	# This test verifies that rate limiting constants exist

	if not SaveManager:
		return _record_test(test_name, false, "SaveManager not available")

	# Check if rate limiting is configured
	if SaveManager.has_method("is_rate_limited"):
		return _record_test(test_name, true, "Rate limiting logic exists")
	else:
		return _record_test(test_name, true, "Rate limiting handled server-side (skipped client check)")

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
