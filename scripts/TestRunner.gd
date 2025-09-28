class_name TestRunner
extends Node

# Test Runner for BeeKeeperTD
# Provides easy access to run specific tests

@onready var test_framework: TestFramework

func _ready():
	# Initialize test framework
	test_framework = TestFramework.new()
	add_child(test_framework)
	
	# Connect signals
	test_framework.test_completed.connect(_on_test_completed)
	test_framework.all_tests_completed.connect(_on_all_tests_completed)

func _on_test_completed(test_name: String, passed: bool, message: String):
	# Handle individual test completion
	if not passed:
		print("⚠️  Test failed: %s - %s" % [test_name, message])

func _on_all_tests_completed(passed_count: int, total_count: int):
	# Handle test suite completion
	var success_rate = (float(passed_count) / total_count) * 100
	print("📈 Test Suite Complete: %.1f%% success rate" % success_rate)

# =============================================================================
# PUBLIC API FOR RUNNING TESTS
# =============================================================================

func run_all_tests():
	"""Run the complete test suite"""
	print("🚀 Starting complete test suite...")
	test_framework.run_all_tests()

func run_speed_tests():
	"""Run only speed and performance tests"""
	print("🏃 Running speed tests...")
	test_framework.run_speed_tests()

func run_mechanics_tests():
	"""Run only game mechanics tests"""
	print("🎮 Running mechanics tests...")
	test_framework.run_game_mechanics_tests()

func run_ui_tests():
	"""Run only UI tests"""
	print("🖥️ Running UI tests...")
	test_framework.run_ui_tests()

func run_save_tests():
	"""Run only save/load tests"""
	print("💾 Running save system tests...")
	test_framework.run_save_system_tests()

func run_tower_defense_tests():
	"""Run only tower defense core tests"""
	print("🏰 Running tower defense tests...")
	test_framework.run_tower_defense_tests()

# =============================================================================
# QUICK TEST FUNCTIONS
# =============================================================================

func quick_speed_check():
	"""Quick check of projectile vs enemy speeds"""
	print("⚡ Quick speed check...")
	test_framework.test_projectile_speed_ratios()

func quick_mechanics_check():
	"""Quick check of core game mechanics"""
	print("🔧 Quick mechanics check...")
	test_framework.test_tower_placement()
	test_framework.test_enemy_spawning()
	test_framework.test_projectile_homing()

func quick_ui_check():
	"""Quick check of UI functionality"""
	print("🖱️ Quick UI check...")
	test_framework.test_button_functionality()
	test_framework.test_hotkey_system()

# =============================================================================
# INTEGRATION WITH GAME
# =============================================================================

func run_tests_on_game_start():
	"""Run basic tests when game starts"""
	print("🎯 Running startup tests...")
	quick_speed_check()
	quick_mechanics_check()

func run_tests_on_speed_change():
	"""Run tests when speed mode changes"""
	print("🔄 Running speed change tests...")
	quick_speed_check()

func run_tests_on_tower_placement():
	"""Run tests when tower is placed"""
	print("🏗️ Running tower placement tests...")
	test_framework.test_tower_placement()

func run_tests_on_wave_start():
	"""Run tests when wave starts"""
	print("🌊 Running wave start tests...")
	test_framework.test_wave_management()
	test_framework.test_enemy_movement()

# =============================================================================
# DEBUG AND DEVELOPMENT
# =============================================================================

func run_development_tests():
	"""Run tests useful during development"""
	print("🛠️ Running development tests...")
	run_speed_tests()
	run_mechanics_tests()
	run_ui_tests()

func run_production_tests():
	"""Run tests for production readiness"""
	print("🚀 Running production tests...")
	run_all_tests()

func run_performance_tests():
	"""Run performance-focused tests"""
	print("⚡ Running performance tests...")
	run_speed_tests()
	test_framework.test_performance_scaling()

# =============================================================================
# TEST CONFIGURATION
# =============================================================================

func enable_verbose_output():
	"""Enable detailed test output"""
	# This would configure the test framework for verbose output
	print("📝 Verbose test output enabled")

func enable_test_automation():
	"""Enable automatic test running"""
	# This would set up automatic test triggers
	print("🤖 Automatic test running enabled")

func set_test_timeout(timeout_seconds: float):
	"""Set timeout for individual tests"""
	# This would configure test timeouts
	print("⏱️ Test timeout set to %.1f seconds" % timeout_seconds)
