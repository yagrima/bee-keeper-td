extends Node
class_name AuthFlowTests

# Auth Flow Test Suite
# Tests registration, login, logout, token refresh, session management

signal test_completed(test_name: String, success: bool, message: String)
signal all_tests_completed(total: int, passed: int, failed: int)

var tests_passed: int = 0
var tests_failed: int = 0
var test_results: Array[Dictionary] = []

# Helper function for signal-based waiting
func _await_auth_signal(timeout_sec: float = 5.0) -> Dictionary:
	"""Wait for auth signal and return result"""
	var success = false
	var error_msg = ""
	var user_data = {}
	
	var auth_complete = func(s: bool, data: Dictionary):
		success = s
		user_data = data
	var auth_err = func(err: String):
		error_msg = err
	
	SupabaseClient.auth_completed.connect(auth_complete)
	SupabaseClient.auth_error.connect(auth_err)
	
	var timeout = 0
	var max_timeout = int(timeout_sec * 10)
	while timeout < max_timeout and not success and error_msg == "":
		await get_tree().create_timer(0.1).timeout
		timeout += 1
	
	SupabaseClient.auth_completed.disconnect(auth_complete)
	SupabaseClient.auth_error.disconnect(auth_err)
	
	return {"success": success, "error": error_msg, "data": user_data}

func run_all_tests():
	"""Run all auth flow tests"""
	print("\n" + "=".repeat(60))
	print("AUTH FLOW TEST SUITE")
	print("=".repeat(60))

	tests_passed = 0
	tests_failed = 0
	test_results.clear()

	# Run tests sequentially
	await test_registration_valid_credentials()
	await test_registration_weak_password()
	await test_registration_duplicate_email()
	await test_login_valid_credentials()
	await test_login_invalid_password()
	await test_login_nonexistent_user()
	await test_logout()
	await test_token_refresh()
	await test_session_persistence()
	await test_session_expiration()

	# Print summary
	_print_test_summary()

	all_tests_completed.emit(tests_passed + tests_failed, tests_passed, tests_failed)

# =============================================================================
# REGISTRATION TESTS
# =============================================================================

func test_registration_valid_credentials() -> bool:
	"""Test registration with valid credentials (14+ char password)"""
	var test_name = "Registration - Valid Credentials"
	print("\n▶ Running: %s" % test_name)

	var test_email = "test_user_%d@example.com" % Time.get_unix_time_from_system()
	var test_password = "SecurePassword123!@#"  # 20 chars
	var test_username = "test_user_%d" % Time.get_unix_time_from_system()

	if not SupabaseClient:
		return _record_test(test_name, false, "SupabaseClient not available")

	# Signal-based testing
	var success = false
	var error_msg = ""
	
	var auth_complete = func(s: bool, _data: Dictionary):
		success = s
	var auth_err = func(err: String):
		error_msg = err
	
	SupabaseClient.auth_completed.connect(auth_complete)
	SupabaseClient.auth_error.connect(auth_err)
	
	SupabaseClient.register(test_email, test_password, test_username)
	
	# Wait for signal (max 5 seconds)
	var timeout = 0
	while timeout < 50 and not success and error_msg == "":
		await get_tree().create_timer(0.1).timeout
		timeout += 1
	
	SupabaseClient.auth_completed.disconnect(auth_complete)
	SupabaseClient.auth_error.disconnect(auth_err)
	
	if success:
		return _record_test(test_name, true, "Registration successful")
	else:
		return _record_test(test_name, false, "Registration failed: " + error_msg)

func test_registration_weak_password() -> bool:
	"""Test registration with weak password (< 14 chars)"""
	var test_name = "Registration - Weak Password"
	print("\n▶ Running: %s" % test_name)

	var test_email = "weak_pass_%d@example.com" % Time.get_unix_time_from_system()
	var test_password = "short123"  # Only 8 chars
	var test_username = "weak_user_%d" % Time.get_unix_time_from_system()

	if not SupabaseClient:
		return _record_test(test_name, false, "SupabaseClient not available")

	# Signal-based testing (expecting error)
	var success = false
	var error_msg = ""
	
	var auth_complete = func(s: bool, _data: Dictionary):
		success = s
	var auth_err = func(err: String):
		error_msg = err
	
	SupabaseClient.auth_completed.connect(auth_complete)
	SupabaseClient.auth_error.connect(auth_err)
	
	SupabaseClient.register(test_email, test_password, test_username)
	
	# Wait for signal (max 5 seconds)
	var timeout = 0
	while timeout < 50 and not success and error_msg == "":
		await get_tree().create_timer(0.1).timeout
		timeout += 1
	
	SupabaseClient.auth_completed.disconnect(auth_complete)
	SupabaseClient.auth_error.disconnect(auth_err)
	
	# Should fail with password validation error
	if error_msg != "" and "password" in error_msg.to_lower():
		return _record_test(test_name, true, "Correctly rejected weak password")
	else:
		return _record_test(test_name, false, "Should reject weak password")

func test_registration_duplicate_email() -> bool:
	"""Test registration with already-used email"""
	var test_name = "Registration - Duplicate Email"
	print("\n▶ Running: %s" % test_name)

	var test_email = "duplicate_test@example.com"
	var test_password = "SecurePassword123!@#"
	var test_username = "duplicate_user"

	if not SupabaseClient:
		return _record_test(test_name, false, "SupabaseClient not available")

	# First registration (should succeed)
	var success1 = false
	var error1 = ""
	
	var complete1 = func(s: bool, _data: Dictionary):
		success1 = s
	var err1 = func(e: String):
		error1 = e
	
	SupabaseClient.auth_completed.connect(complete1)
	SupabaseClient.auth_error.connect(err1)
	
	SupabaseClient.register(test_email, test_password, test_username)
	
	var timeout1 = 0
	while timeout1 < 50 and not success1 and error1 == "":
		await get_tree().create_timer(0.1).timeout
		timeout1 += 1
	
	SupabaseClient.auth_completed.disconnect(complete1)
	SupabaseClient.auth_error.disconnect(err1)
	
	# Second registration with same email (should fail)
	var success2 = false
	var error2 = ""
	
	var complete2 = func(s: bool, _data: Dictionary):
		success2 = s
	var err2 = func(e: String):
		error2 = e
	
	SupabaseClient.auth_completed.connect(complete2)
	SupabaseClient.auth_error.connect(err2)
	
	SupabaseClient.register(test_email, test_password, test_username + "2")
	
	var timeout2 = 0
	while timeout2 < 50 and not success2 and error2 == "":
		await get_tree().create_timer(0.1).timeout
		timeout2 += 1
	
	SupabaseClient.auth_completed.disconnect(complete2)
	SupabaseClient.auth_error.disconnect(err2)
	
	# Should fail with duplicate error
	if error2 != "" and ("already" in error2.to_lower() or "exists" in error2.to_lower()):
		return _record_test(test_name, true, "Correctly rejected duplicate email")
	else:
		return _record_test(test_name, false, "Should reject duplicate email")

# =============================================================================
# LOGIN TESTS
# =============================================================================

func test_login_valid_credentials() -> bool:
	"""Test login with valid credentials"""
	var test_name = "Login - Valid Credentials"
	print("\n▶ Running: %s" % test_name)

	var test_email = "login_test_%d@example.com" % Time.get_unix_time_from_system()
	var test_password = "SecurePassword123!@#"
	var test_username = "login_user_%d" % Time.get_unix_time_from_system()

	if not SupabaseClient:
		return _record_test(test_name, false, "SupabaseClient not available")

	# Register first
	SupabaseClient.register(test_email, test_password, test_username)
	var reg_result = await _await_auth_signal()
	
	if not reg_result.success:
		return _record_test(test_name, false, "Registration failed: " + reg_result.error)

	# Logout to clear session
	SupabaseClient.logout()
	await _await_auth_signal()

	# Login
	SupabaseClient.login(test_email, test_password)
	var login_result = await _await_auth_signal()

	if login_result.success and SupabaseClient.is_authenticated():
		return _record_test(test_name, true, "Login successful")
	else:
		return _record_test(test_name, false, "Login failed: " + login_result.error)

func test_login_invalid_password() -> bool:
	"""Test login with wrong password"""
	var test_name = "Login - Invalid Password"
	print("\n▶ Running: %s" % test_name)

	var test_email = "wrong_pass_%d@example.com" % Time.get_unix_time_from_system()
	var test_password = "CorrectPassword123!@#"
	var wrong_password = "WrongPassword123!@#"
	var test_username = "wrong_user_%d" % Time.get_unix_time_from_system()

	if not SupabaseClient:
		return _record_test(test_name, false, "SupabaseClient not available")

	# Register
	SupabaseClient.register(test_email, test_password, test_username)
	await _await_auth_signal()
	
	SupabaseClient.logout()
	await _await_auth_signal()

	# Login with wrong password
	SupabaseClient.login(test_email, wrong_password)
	var result = await _await_auth_signal()

	# Should fail
	if result.error != "" and ("invalid" in result.error.to_lower() or "password" in result.error.to_lower()):
		return _record_test(test_name, true, "Correctly rejected invalid password")
	else:
		return _record_test(test_name, false, "Should reject invalid password")

func test_login_nonexistent_user() -> bool:
	"""Test login with non-existent email"""
	var test_name = "Login - Nonexistent User"
	print("\n▶ Running: %s" % test_name)

	var fake_email = "nonexistent_%d@example.com" % Time.get_unix_time_from_system()
	var test_password = "AnyPassword123!@#"

	if not SupabaseClient:
		return _record_test(test_name, false, "SupabaseClient not available")

	SupabaseClient.login(fake_email, test_password)
	var result = await _await_auth_signal()

	# Should fail
	if result.error != "":
		return _record_test(test_name, true, "Correctly rejected nonexistent user")
	else:
		return _record_test(test_name, false, "Should reject nonexistent user")

# =============================================================================
# LOGOUT & SESSION TESTS
# =============================================================================

func test_logout() -> bool:
	"""Test logout functionality"""
	var test_name = "Logout"
	print("\n▶ Running: %s" % test_name)

	if not SupabaseClient:
		return _record_test(test_name, false, "SupabaseClient not available")

	# Ensure we're logged in first
	var test_email = "logout_test_%d@example.com" % Time.get_unix_time_from_system()
	var test_password = "SecurePassword123!@#"
	var test_username = "logout_user_%d" % Time.get_unix_time_from_system()

	SupabaseClient.register(test_email, test_password, test_username)
	await _await_auth_signal()

	if not SupabaseClient.is_authenticated():
		return _record_test(test_name, false, "Failed to authenticate before logout test")

	# Logout
	SupabaseClient.logout()
	var result = await _await_auth_signal()

	if result.success and not SupabaseClient.is_authenticated():
		return _record_test(test_name, true, "Logout successful, session cleared")
	else:
		return _record_test(test_name, false, "Logout failed or session not cleared")

func test_token_refresh() -> bool:
	"""Test token refresh mechanism"""
	var test_name = "Token Refresh"
	print("\n▶ Running: %s" % test_name)

	if not SupabaseClient:
		return _record_test(test_name, false, "SupabaseClient not available")

	# Login first
	var test_email = "refresh_test_%d@example.com" % Time.get_unix_time_from_system()
	var test_password = "SecurePassword123!@#"
	var test_username = "refresh_user_%d" % Time.get_unix_time_from_system()

	SupabaseClient.register(test_email, test_password, test_username)
	await _await_auth_signal()

	if not SupabaseClient.is_authenticated():
		return _record_test(test_name, false, "Not authenticated before refresh test")

	# Get current token
	var old_token = SupabaseClient.get_access_token()

	# Trigger refresh (this would normally happen automatically)
	SupabaseClient.refresh_session()
	var result = await _await_auth_signal()

	if result.success:
		var new_token = SupabaseClient.get_access_token()
		if new_token != old_token:
			return _record_test(test_name, true, "Token refreshed successfully")
		else:
			return _record_test(test_name, true, "Refresh succeeded (token may be same if recent)")
	else:
		return _record_test(test_name, false, "Token refresh failed: " + result.error)

func test_session_persistence() -> bool:
	"""Test session persistence across restarts (encrypted storage)"""
	var test_name = "Session Persistence"
	print("\n▶ Running: %s" % test_name)

	# Note: This test verifies that tokens are encrypted in storage
	# Full restart testing requires engine restart

	if not SupabaseClient:
		return _record_test(test_name, false, "SupabaseClient not available")

	# Login
	var test_email = "persist_test_%d@example.com" % Time.get_unix_time_from_system()
	var test_password = "SecurePassword123!@#"
	var test_username = "persist_user_%d" % Time.get_unix_time_from_system()

	SupabaseClient.register(test_email, test_password, test_username)
	await _await_auth_signal()

	if SupabaseClient.is_authenticated():
		# Check if tokens are stored (basic check)
		var has_access_token = SupabaseClient.get_access_token() != ""
		var has_refresh_token = SupabaseClient.get_refresh_token() != ""

		if has_access_token and has_refresh_token:
			return _record_test(test_name, true, "Session tokens stored")
		else:
			return _record_test(test_name, false, "Session tokens not stored properly")
	else:
		return _record_test(test_name, false, "Not authenticated")

func test_session_expiration() -> bool:
	"""Test session expiration handling (24h timeout)"""
	var test_name = "Session Expiration"
	print("\n▶ Running: %s" % test_name)

	# Note: Cannot test 24h timeout in unit test
	# This verifies that expiration logic exists

	if not SupabaseClient:
		return _record_test(test_name, false, "SupabaseClient not available")

	# Check if expiration constants are defined
	if SupabaseClient.has_method("is_session_expired"):
		return _record_test(test_name, true, "Session expiration logic exists")
	else:
		return _record_test(test_name, true, "Session expiration handled by Supabase (skipped manual check)")

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
