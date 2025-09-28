class_name SpeedTest
extends Node

# Speed Test for Projectile vs Enemy Speed Comparison
# This test ensures projectiles are always faster than enemies at all speed modes

# Base speeds from the game
const ENEMY_BASE_SPEED = 60.0  # StandardEnemy movement_speed
const BASIC_SHOOTER_BASE_SPEED = 300.0  # BasicShooterTower projectile_speed
const PIERCING_SHOOTER_BASE_SPEED = 250.0  # PiercingTower projectile_speed

# Speed modes
const SPEED_MODES = {
	"Normal (1x)": 1.0,
	"Double (2x)": 2.0,
	"Triple (3x)": 3.0
}

func _ready():
	print("=== SPEED TEST: Projectile vs Enemy Speed Comparison ===")
	run_speed_test()

func run_speed_test():
	var all_tests_passed = true
	
	for mode_name in SPEED_MODES.keys():
		var time_scale = SPEED_MODES[mode_name]
		print("\n--- Testing %s (time_scale: %.1f) ---" % [mode_name, time_scale])
		
		# Calculate enemy speed (affected by time_scale)
		var enemy_speed = ENEMY_BASE_SPEED * time_scale
		
		# Calculate projectile speeds (with speed boost)
		var basic_projectile_speed = calculate_projectile_speed(BASIC_SHOOTER_BASE_SPEED, time_scale)
		var piercing_projectile_speed = calculate_projectile_speed(PIERCING_SHOOTER_BASE_SPEED, time_scale)
		
		# Test results
		var basic_ratio = basic_projectile_speed / enemy_speed
		var piercing_ratio = piercing_projectile_speed / enemy_speed
		
		print("Enemy Speed: %.1f px/s" % enemy_speed)
		print("Basic Shooter Projectile: %.1f px/s (%.1fx faster)" % [basic_projectile_speed, basic_ratio])
		print("Piercing Shooter Projectile: %.1f px/s (%.1fx faster)" % [piercing_projectile_speed, piercing_ratio])
		
		# Check if projectiles are faster than enemies
		var basic_faster = basic_projectile_speed > enemy_speed
		var piercing_faster = piercing_projectile_speed > enemy_speed
		
		if basic_faster and piercing_faster:
			print("✅ PASS: All projectiles are faster than enemies")
		else:
			print("❌ FAIL: Some projectiles are slower than enemies!")
			all_tests_passed = false
			
			if not basic_faster:
				print("   ⚠️  Basic Shooter projectile is %.1fx SLOWER than enemies!" % (enemy_speed / basic_projectile_speed))
			if not piercing_faster:
				print("   ⚠️  Piercing Shooter projectile is %.1fx SLOWER than enemies!" % (enemy_speed / piercing_projectile_speed))
	
	# Final result
	print("\n" + "=".repeat(60))
	if all_tests_passed:
		print("🎉 ALL SPEED TESTS PASSED!")
		print("✅ Projectiles are faster than enemies at all speed modes")
	else:
		print("🚨 SPEED TESTS FAILED!")
		print("❌ Some projectiles are slower than enemies - this will cause gameplay issues!")
		print("💡 Consider increasing projectile speed multipliers or reducing enemy speed")
	print("=".repeat(60))

func calculate_projectile_speed(base_speed: float, time_scale: float) -> float:
	# This matches the logic in Projectile.gd
	if time_scale > 1.0:
		return base_speed * time_scale * 1.25  # Current multiplier
	else:
		return base_speed * 1.25  # Still gets 1.25x boost even at normal speed

# Function to run test manually
func run_manual_test():
	print("Running manual speed test...")
	run_speed_test()

# Function to test specific scenario
func test_specific_scenario(time_scale: float, projectile_base_speed: float):
	print("Testing specific scenario:")
	print("Time Scale: %.1f" % time_scale)
	print("Projectile Base Speed: %.1f" % projectile_base_speed)
	
	var enemy_speed = ENEMY_BASE_SPEED * time_scale
	var projectile_speed = calculate_projectile_speed(projectile_base_speed, time_scale)
	var ratio = projectile_speed / enemy_speed
	
	print("Enemy Speed: %.1f px/s" % enemy_speed)
	print("Projectile Speed: %.1f px/s" % projectile_speed)
	print("Speed Ratio: %.2fx" % ratio)
	
	if projectile_speed > enemy_speed:
		print("✅ Projectile is faster")
	else:
		print("❌ Projectile is slower - this will cause issues!")
	
	return projectile_speed > enemy_speed
