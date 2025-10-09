class_name TestReporter
extends RefCounted

# =============================================================================
# TEST REPORTER
# =============================================================================
# Handles test result recording and report generation
# - Result tracking
# - Report generation
# - Statistics calculation
# =============================================================================

signal test_completed(test_name: String, passed: bool, message: String)
signal all_tests_completed(passed_count: int, total_count: int)

var test_results: Array[Dictionary] = []
var current_test_suite: String = ""

func set_current_suite(suite_name: String):
	"""Set the current test suite name"""
	current_test_suite = suite_name

func record_test_result(test_name: String, passed: bool, message: String):
	"""Record a test result"""
	var result = {
		"suite": current_test_suite,
		"name": test_name,
		"passed": passed,
		"message": message,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	test_results.append(result)
	
	var status = "✅ PASS" if passed else "❌ FAIL"
	print("  %s %s: %s" % [status, test_name, message])
	
	test_completed.emit(test_name, passed, message)

func generate_report():
	"""Generate final test report with statistics"""
	print("\n" + "=".repeat(60))
	print("📊 TEST REPORT")
	print("=".repeat(60))
	
	var total_tests = test_results.size()
	if total_tests == 0:
		print("⚠️  No tests were run")
		print("=".repeat(60))
		return
	
	var passed_tests = test_results.filter(func(result): return result.passed).size()
	var failed_tests = total_tests - passed_tests
	
	print("Total Tests: %d" % total_tests)
	print("Passed: %d" % passed_tests)
	print("Failed: %d" % failed_tests)
	print("Success Rate: %.1f%%" % ((float(passed_tests) / total_tests) * 100))
	
	if failed_tests > 0:
		print("\n❌ FAILED TESTS:")
		for result in test_results:
			if not result.passed:
				print("  - [%s] %s: %s" % [result.suite, result.name, result.message])
	
	print("=".repeat(60))
	
	if failed_tests == 0:
		print("🎉 ALL TESTS PASSED!")
	else:
		print("⚠️  %d TESTS FAILED - REVIEW REQUIRED" % failed_tests)
	
	all_tests_completed.emit(passed_tests, total_tests)

func clear_results():
	"""Clear all test results"""
	test_results.clear()

func get_results() -> Array[Dictionary]:
	"""Get all test results"""
	return test_results

func get_failed_tests() -> Array[Dictionary]:
	"""Get only failed tests"""
	return test_results.filter(func(result): return not result.passed)

func get_passed_tests() -> Array[Dictionary]:
	"""Get only passed tests"""
	return test_results.filter(func(result): return result.passed)

func get_success_rate() -> float:
	"""Get success rate as percentage"""
	var total = test_results.size()
	if total == 0:
		return 0.0
	var passed = get_passed_tests().size()
	return (float(passed) / total) * 100.0
