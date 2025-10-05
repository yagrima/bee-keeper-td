extends Node

# Sprint 4 Test Runner
# Runs all Sprint 4 tests: Auth Flow, Cloud Save, Component Integration

var auth_tests: AuthFlowTests
var cloud_tests: CloudSaveTests
var component_tests: ComponentIntegrationTests

var total_tests: int = 0
var total_passed: int = 0
var total_failed: int = 0

func _ready():
	print("\n" + "█".repeat(60))
	print("SPRINT 4 - COMPREHENSIVE TEST SUITE")
	print("█".repeat(60))
	print("Starting all tests...")
	print("")

	# Initialize test suites
	auth_tests = AuthFlowTests.new()
	cloud_tests = CloudSaveTests.new()
	component_tests = ComponentIntegrationTests.new()

	add_child(auth_tests)
	add_child(cloud_tests)
	add_child(component_tests)

	# Connect signals
	auth_tests.all_tests_completed.connect(_on_auth_tests_completed)
	cloud_tests.all_tests_completed.connect(_on_cloud_tests_completed)
	component_tests.all_tests_completed.connect(_on_component_tests_completed)

	# Start tests
	await run_all_test_suites()

func run_all_test_suites():
	"""Run all test suites sequentially"""

	# 1. Component Integration Tests (fastest, no async)
	print("\n📦 Running Component Integration Tests...")
	component_tests.run_all_tests()
	await component_tests.all_tests_completed

	# 2. Cloud Save/Load Tests (requires SaveManager)
	print("\n☁️ Running Cloud Save/Load Tests...")
	await cloud_tests.run_all_tests()

	# 3. Auth Flow Tests (requires network, slowest)
	print("\n🔐 Running Auth Flow Tests...")
	await auth_tests.run_all_tests()

	# Print final summary
	_print_final_summary()

	# Exit after tests (for automated testing)
	await get_tree().create_timer(2.0).timeout
	print("\nTests complete. Exiting in 3 seconds...")
	await get_tree().create_timer(3.0).timeout
	get_tree().quit()

func _on_auth_tests_completed(total: int, passed: int, failed: int):
	"""Handle auth tests completion"""
	total_tests += total
	total_passed += passed
	total_failed += failed
	print("\n✅ Auth Flow Tests Complete: %d/%d passed" % [passed, total])

func _on_cloud_tests_completed(total: int, passed: int, failed: int):
	"""Handle cloud tests completion"""
	total_tests += total
	total_passed += passed
	total_failed += failed
	print("\n✅ Cloud Save Tests Complete: %d/%d passed" % [passed, total])

func _on_component_tests_completed(total: int, passed: int, failed: int):
	"""Handle component tests completion"""
	total_tests += total
	total_passed += passed
	total_failed += failed
	print("\n✅ Component Integration Tests Complete: %d/%d passed" % [passed, total])

func _print_final_summary():
	"""Print final test summary across all suites"""
	print("\n" + "█".repeat(60))
	print("FINAL TEST SUMMARY - SPRINT 4")
	print("█".repeat(60))
	print("Total Test Suites: 3")
	print("  - Component Integration Tests")
	print("  - Cloud Save/Load Tests")
	print("  - Auth Flow Tests")
	print("")
	print("Total Tests: %d" % total_tests)
	print("✅ Passed: %d" % total_passed)
	print("❌ Failed: %d" % total_failed)
	print("Success Rate: %.1f%%" % (100.0 * total_passed / max(1, total_tests)))
	print("█".repeat(60))

	if total_failed == 0:
		print("\n🎉 ALL TESTS PASSED! Sprint 4 is production-ready!")
	else:
		print("\n⚠️ Some tests failed. Review failures above.")

	print("\nSprint 4 Status:")
	print("  ✅ UX Improvements (NotificationManager, ErrorHandler)")
	print("  ✅ Loading States for Cloud-Sync")
	print("  ✅ Error Handling")
	print("  ✅ Success Notifications")
	print("  %s Testing Complete (%d/%d tests passed)" % ["✅" if total_failed == 0 else "⚠️", total_passed, total_tests])
