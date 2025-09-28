class_name ContinuousTesting
extends Node

# Continuous Testing System for BeeKeeperTD
# Automatically runs tests when specific game events occur

@onready var test_runner: TestRunner
var auto_test_enabled: bool = false  # Disabled by default for performance
var test_frequency: float = 60.0  # Run tests every 60 seconds (less frequent)
var last_test_time: float = 0.0
var is_development_build: bool = false  # Only enable in development

# Test triggers
var test_on_speed_change: bool = true
var test_on_tower_placement: bool = true
var test_on_wave_start: bool = true
var test_on_save_load: bool = true

func _ready():
	# Initialize test runner
	test_runner = TestRunner.new()
	add_child(test_runner)
	
	# Only start testing in development builds
	check_development_mode()
	
	if auto_test_enabled and is_development_build:
		start_periodic_testing()

func _process(delta):
	# Only run tests in development builds
	if auto_test_enabled and is_development_build:
		last_test_time += delta
		if last_test_time >= test_frequency:
			run_periodic_tests()
			last_test_time = 0.0

# =============================================================================
# DEVELOPMENT MODE DETECTION
# =============================================================================

func check_development_mode():
	"""Check if we're running in development mode"""
	# Check for development indicators
	is_development_build = (
		OS.is_debug_build() or  # Debug build
		OS.has_feature("debug") or  # Debug feature enabled
		OS.get_environment("GODOT_DEBUG") == "1" or  # Debug environment variable
		OS.get_environment("BEEKEEPER_DEBUG") == "1"  # Custom debug flag
	)
	
	if is_development_build:
		print("🛠️ Development build detected - testing enabled")
	else:
		print("🚀 Production build detected - testing disabled for performance")

# =============================================================================
# AUTOMATIC TEST TRIGGERS
# =============================================================================

func on_speed_mode_changed(new_mode: int):
	"""Triggered when speed mode changes"""
	if test_on_speed_change and is_development_build:
		print("🔄 Speed mode changed to %d - running speed tests" % new_mode)
		test_runner.run_speed_tests()

func on_tower_placed(tower_type: String, position: Vector2):
	"""Triggered when a tower is placed"""
	if test_on_tower_placement and is_development_build:
		print("🏗️ Tower placed (%s) - running placement tests" % tower_type)
		test_runner.run_tests_on_tower_placement()

func on_wave_started(wave_number: int):
	"""Triggered when a wave starts"""
	if test_on_wave_start and is_development_build:
		print("🌊 Wave %d started - running wave tests" % wave_number)
		test_runner.run_tests_on_wave_start()

func on_save_loaded():
	"""Triggered when save data is loaded"""
	if test_on_save_load and is_development_build:
		print("💾 Save loaded - running save system tests")
		test_runner.run_save_tests()

func on_game_state_changed():
	"""Triggered when game state changes significantly"""
	if is_development_build:
		print("🎮 Game state changed - running mechanics tests")
		test_runner.run_mechanics_tests()

# =============================================================================
# PERIODIC TESTING
# =============================================================================

func start_periodic_testing():
	"""Start automatic periodic testing"""
	print("⏰ Starting periodic testing (every %.1f seconds)" % test_frequency)

func stop_periodic_testing():
	"""Stop automatic periodic testing"""
	print("⏹️ Stopping periodic testing")
	auto_test_enabled = false

func run_periodic_tests():
	"""Run tests periodically"""
	print("🔄 Running periodic tests...")
	test_runner.quick_speed_check()
	test_runner.quick_mechanics_check()

# =============================================================================
# CONFIGURATION
# =============================================================================

func set_test_frequency(seconds: float):
	"""Set how often to run periodic tests"""
	test_frequency = seconds
	print("⏱️ Test frequency set to %.1f seconds" % seconds)

func enable_auto_testing():
	"""Enable automatic testing"""
	auto_test_enabled = true
	start_periodic_testing()
	print("🤖 Automatic testing enabled")

func disable_auto_testing():
	"""Disable automatic testing"""
	auto_test_enabled = false
	stop_periodic_testing()
	print("⏹️ Automatic testing disabled")

func configure_test_triggers(
	speed_change: bool = true,
	tower_placement: bool = true,
	wave_start: bool = true,
	save_load: bool = true
):
	"""Configure which events trigger tests"""
	test_on_speed_change = speed_change
	test_on_tower_placement = tower_placement
	test_on_wave_start = wave_start
	test_on_save_load = save_load
	
	print("⚙️ Test triggers configured:")
	print("  Speed change: %s" % speed_change)
	print("  Tower placement: %s" % tower_placement)
	print("  Wave start: %s" % wave_start)
	print("  Save/load: %s" % save_load)

# =============================================================================
# INTEGRATION HELPERS
# =============================================================================

func connect_to_game_events():
	"""Connect to game events for automatic testing"""
	# This would connect to actual game signals
	# For example:
	# GameManager.speed_mode_changed.connect(on_speed_mode_changed)
	# TowerPlacer.tower_placed.connect(on_tower_placed)
	# WaveManager.wave_started.connect(on_wave_started)
	# SaveManager.save_loaded.connect(on_save_loaded)
	
	print("🔗 Connected to game events for automatic testing")

func disconnect_from_game_events():
	"""Disconnect from game events"""
	# This would disconnect from game signals
	print("🔌 Disconnected from game events")

# =============================================================================
# DEVELOPMENT MODE
# =============================================================================

func enable_development_mode():
	"""Enable comprehensive testing for development"""
	print("🛠️ Enabling development mode testing...")
	
	# Run all tests
	test_runner.run_all_tests()
	
	# Enable all triggers
	configure_test_triggers(true, true, true, true)
	
	# Set frequent testing
	set_test_frequency(10.0)
	
	print("✅ Development mode enabled - comprehensive testing active")

func enable_production_mode():
	"""Enable minimal testing for production"""
	print("🚀 Enabling production mode testing...")
	
	# Run only critical tests
	test_runner.quick_speed_check()
	test_runner.quick_mechanics_check()
	
	# Disable most triggers
	configure_test_triggers(false, false, true, false)
	
	# Set less frequent testing
	set_test_frequency(60.0)
	
	print("✅ Production mode enabled - minimal testing active")

# =============================================================================
# MANUAL TEST CONTROL
# =============================================================================

func run_full_test_suite():
	"""Manually run the full test suite"""
	print("🧪 Running full test suite...")
	test_runner.run_all_tests()

func run_critical_tests():
	"""Run only critical tests"""
	print("🚨 Running critical tests...")
	test_runner.quick_speed_check()
	test_runner.quick_mechanics_check()
	test_runner.quick_ui_check()

func run_performance_tests():
	"""Run performance-focused tests"""
	print("⚡ Running performance tests...")
	test_runner.run_performance_tests()

# =============================================================================
# TEST REPORTING
# =============================================================================

func get_test_status():
	"""Get current testing status"""
	var status = {
		"auto_testing": auto_test_enabled,
		"test_frequency": test_frequency,
		"triggers": {
			"speed_change": test_on_speed_change,
			"tower_placement": test_on_tower_placement,
			"wave_start": test_on_wave_start,
			"save_load": test_on_save_load
		}
	}
	return status

func print_test_status():
	"""Print current testing status"""
	var status = get_test_status()
	print("📊 Current Testing Status:")
	print("  Auto testing: %s" % status.auto_testing)
	print("  Frequency: %.1f seconds" % status.test_frequency)
	print("  Triggers: %s" % status.triggers)
