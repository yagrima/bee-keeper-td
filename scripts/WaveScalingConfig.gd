class_name WaveScalingConfig
extends Resource

# Wave Scaling Configuration for BeeKeeperTD
# Simple configuration for enemy scaling across waves

# Base scaling factor per wave (1.3 = 30% increase per wave)
@export var base_scaling_factor: float = 1.3

# Simple scaling configuration
@export var health_scaling: float = 1.0      # Full health scaling
@export var reward_scaling: float = 0.5     # 50% of health scaling

# =============================================================================
# SIMPLE API FUNCTIONS
# =============================================================================

func get_scaling_factor(wave_number: int) -> float:
	"""Get the base scaling factor for a wave"""
	if wave_number <= 1:
		return 1.0
	
	return pow(base_scaling_factor, wave_number - 1)

func get_scaling_info(wave_number: int) -> String:
	"""Get human-readable scaling information for a wave"""
	if wave_number <= 1:
		return "Normal difficulty"
	
	var scaling_factor = get_scaling_factor(wave_number)
	var percentage = int((scaling_factor - 1.0) * 100)
	
	return "%d%% stronger" % percentage
