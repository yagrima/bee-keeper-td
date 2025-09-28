class_name TestingConfig
extends Node

# Testing Configuration for BeeKeeperTD
# Controls when and how tests are run

# Environment-based configuration
static var is_development: bool = false
static var is_production: bool = false
static var testing_enabled: bool = false

# Performance settings
static var test_frequency: float = 60.0  # Seconds between tests
static var max_test_duration: float = 1.0  # Max seconds per test
static var enable_verbose_logging: bool = false

# Test categories
static var enable_speed_tests: bool = true
static var enable_mechanics_tests: bool = true
static var enable_ui_tests: bool = false  # Disabled by default
static var enable_save_tests: bool = false  # Disabled by default
static var enable_performance_tests: bool = false  # Disabled by default

func _ready():
	detect_environment()
	configure_testing()

func detect_environment():
	"""Detect if we're in development or production"""
	is_development = (
		OS.is_debug_build() or
		OS.has_feature("debug") or
		OS.get_environment("GODOT_DEBUG") == "1" or
		OS.get_environment("BEEKEEPER_DEBUG") == "1"
	)
	
	is_production = not is_development
	
	print("Environment detected:")
	print("  Development: %s" % is_development)
	print("  Production: %s" % is_production)

func configure_testing():
	"""Configure testing based on environment"""
	if is_development:
		configure_development_testing()
	elif is_production:
		configure_production_testing()
	else:
		configure_unknown_testing()

func configure_development_testing():
	"""Configure for development environment"""
	testing_enabled = true
	test_frequency = 30.0  # More frequent in development
	enable_verbose_logging = true
	enable_speed_tests = true
	enable_mechanics_tests = true
	enable_ui_tests = true
	enable_save_tests = true
	enable_performance_tests = true
	
	print("🛠️ Development testing configured")

func configure_production_testing():
	"""Configure for production environment"""
	# Only enable if explicitly requested
	testing_enabled = OS.get_environment("BEEKEEPER_TESTING") == "1"
	test_frequency = 120.0  # Less frequent in production
	enable_verbose_logging = false
	enable_speed_tests = testing_enabled
	enable_mechanics_tests = false
	enable_ui_tests = false
	enable_save_tests = false
	enable_performance_tests = false
	
	if testing_enabled:
		print("🚀 Production testing enabled (lightweight)")
	else:
		print("🚀 Production testing disabled (performance optimized)")

func configure_unknown_testing():
	"""Configure for unknown environment"""
	testing_enabled = false
	print("❓ Unknown environment - testing disabled")

# =============================================================================
# RUNTIME CONFIGURATION
# =============================================================================

static func enable_testing():
	"""Enable testing at runtime"""
	testing_enabled = true
	print("🔧 Testing enabled at runtime")

static func disable_testing():
	"""Disable testing at runtime"""
	testing_enabled = false
	print("⏹️ Testing disabled at runtime")

static func set_test_frequency(frequency: float):
	"""Set test frequency"""
	test_frequency = frequency
	print("⏱️ Test frequency set to %.1f seconds" % frequency)

static func enable_verbose_mode():
	"""Enable verbose logging"""
	enable_verbose_logging = true
	print("📝 Verbose logging enabled")

static func disable_verbose_mode():
	"""Disable verbose logging"""
	enable_verbose_logging = false
	print("📝 Verbose logging disabled")

# =============================================================================
# TEST CATEGORY CONTROL
# =============================================================================

static func enable_speed_testing():
	"""Enable speed tests"""
	enable_speed_tests = true
	print("🏃 Speed testing enabled")

static func disable_speed_testing():
	"""Disable speed tests"""
	enable_speed_tests = false
	print("🏃 Speed testing disabled")

static func enable_mechanics_testing():
	"""Enable mechanics tests"""
	enable_mechanics_tests = true
	print("🎮 Mechanics testing enabled")

static func disable_mechanics_testing():
	"""Disable mechanics tests"""
	enable_mechanics_tests = false
	print("🎮 Mechanics testing disabled")

static func enable_ui_testing():
	"""Enable UI tests"""
	enable_ui_tests = true
	print("🖥️ UI testing enabled")

static func disable_ui_testing():
	"""Disable UI tests"""
	enable_ui_tests = false
	print("🖥️ UI testing disabled")

# =============================================================================
# QUERY FUNCTIONS
# =============================================================================

static func is_testing_enabled() -> bool:
	"""Check if testing is enabled"""
	return testing_enabled

static func should_run_speed_tests() -> bool:
	"""Check if speed tests should run"""
	return testing_enabled and enable_speed_tests

static func should_run_mechanics_tests() -> bool:
	"""Check if mechanics tests should run"""
	return testing_enabled and enable_mechanics_tests

static func should_run_ui_tests() -> bool:
	"""Check if UI tests should run"""
	return testing_enabled and enable_ui_tests

static func should_run_save_tests() -> bool:
	"""Check if save tests should run"""
	return testing_enabled and enable_save_tests

static func should_run_performance_tests() -> bool:
	"""Check if performance tests should run"""
	return testing_enabled and enable_performance_tests

# =============================================================================
# PERFORMANCE OPTIMIZATION
# =============================================================================

static func optimize_for_performance():
	"""Optimize testing for maximum performance"""
	testing_enabled = false
	enable_speed_tests = false
	enable_mechanics_tests = false
	enable_ui_tests = false
	enable_save_tests = false
	enable_performance_tests = false
	enable_verbose_logging = false
	
	print("⚡ Testing optimized for maximum performance")

static func get_performance_impact() -> String:
	"""Get estimated performance impact"""
	if not testing_enabled:
		return "None (testing disabled)"
	
	var impact = "Low"
	if enable_ui_tests or enable_save_tests or enable_performance_tests:
		impact = "Medium"
	if test_frequency < 30.0:
		impact = "High"
	
	return impact

# =============================================================================
# DEBUG INFORMATION
# =============================================================================

static func print_configuration():
	"""Print current testing configuration"""
	print("📊 Testing Configuration:")
	print("  Enabled: %s" % testing_enabled)
	print("  Environment: %s" % ("Development" if is_development else "Production"))
	print("  Frequency: %.1f seconds" % test_frequency)
	print("  Verbose: %s" % enable_verbose_logging)
	print("  Speed Tests: %s" % enable_speed_tests)
	print("  Mechanics Tests: %s" % enable_mechanics_tests)
	print("  UI Tests: %s" % enable_ui_tests)
	print("  Save Tests: %s" % enable_save_tests)
	print("  Performance Tests: %s" % enable_performance_tests)
	print("  Performance Impact: %s" % get_performance_impact())
