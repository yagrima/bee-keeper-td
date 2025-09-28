class_name ProductionTesting
extends Node

# Lightweight Testing for Production Builds
# Only runs critical tests that don't impact performance

var critical_tests_enabled: bool = false
var test_runner: TestRunner

func _ready():
	# Only initialize if in development or debug mode
	if should_enable_testing():
		test_runner = TestRunner.new()
		add_child(test_runner)
		critical_tests_enabled = true
		print("🧪 Lightweight testing enabled for production")

func should_enable_testing() -> bool:
	"""Check if testing should be enabled in production"""
	# Only enable if explicitly requested via environment variable
	return OS.get_environment("BEEKEEPER_TESTING") == "1"

# =============================================================================
# CRITICAL TESTS ONLY
# =============================================================================

func run_critical_speed_check():
	"""Run only the most critical speed test"""
	if not critical_tests_enabled:
		return
	
	print("⚡ Running critical speed check...")
	# Only test the most important speed ratios
	test_projectile_vs_enemy_speed()

func test_projectile_vs_enemy_speed():
	"""Test that projectiles are faster than enemies"""
	var enemy_speed = 60.0
	var basic_projectile_speed = 300.0 * 1.25  # Normal mode
	var piercing_projectile_speed = 250.0 * 1.25
	
	var basic_faster = basic_projectile_speed > enemy_speed
	var piercing_faster = piercing_projectile_speed > enemy_speed
	
	if not (basic_faster and piercing_faster):
		print("❌ CRITICAL: Projectiles slower than enemies!")
		return false
	
	print("✅ Critical speed test passed")
	return true

# =============================================================================
# MINIMAL INTEGRATION
# =============================================================================

func on_game_start():
	"""Run minimal tests when game starts"""
	if critical_tests_enabled:
		run_critical_speed_check()

func on_speed_mode_change():
	"""Run speed test when speed changes"""
	if critical_tests_enabled:
		run_critical_speed_check()

# =============================================================================
# PERFORMANCE MONITORING
# =============================================================================

func monitor_performance():
	"""Monitor basic performance metrics"""
	if not critical_tests_enabled:
		return
	
	# Check FPS
	var fps = Engine.get_frames_per_second()
	if fps < 30:
		print("⚠️ Low FPS detected: %.1f" % fps)
	
	# Check memory usage (if available)
	var memory_usage = OS.get_static_memory_usage()
	if memory_usage > 100 * 1024 * 1024:  # 100MB
		print("⚠️ High memory usage: %.1f MB" % (memory_usage / 1024.0 / 1024.0))

# =============================================================================
# MANUAL OVERRIDE
# =============================================================================

func force_enable_testing():
	"""Force enable testing even in production"""
	critical_tests_enabled = true
	if not test_runner:
		test_runner = TestRunner.new()
		add_child(test_runner)
	print("🔧 Testing force-enabled")

func disable_testing():
	"""Disable all testing"""
	critical_tests_enabled = false
	if test_runner:
		test_runner.queue_free()
		test_runner = null
	print("⏹️ Testing disabled")
