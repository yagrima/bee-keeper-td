class_name StingerTower
extends Tower

func _ready():
	super._ready()

	# Configure Stinger Tower stats
	tower_name = "Stinger Tower"
	tower_type = TowerType.OFFENSIVE
	targeting_mode = TargetingMode.NEAREST

	# Combat stats - Schnellfeuer-Spezialist
	damage = 8.0
	range = 80.0
	attack_speed = 2.5  # Very fast attacks
	penetration = 1

	# Costs
	honey_cost = 20
	upgrade_cost = 30

	# Tower level/tier
	level = 1
	tier = "Minor"

	print("StingerTower initialized: ", tower_name, " with damage: ", damage, " and attack speed: ", attack_speed)

func get_tower_color() -> Color:
	return Color(0.8, 0.2, 0.2)  # Red-ish for aggressive rapid fire

func execute_attack():
	if not current_target or not is_instance_valid(current_target):
		print("StingerTower attack cancelled - no valid target")
		return

	# Create fast, simple projectile
	var projectile = create_stinger_projectile()
	if projectile:
		# Add to scene
		var td_scene = get_tree().current_scene
		var ui_canvas = td_scene.get_node("UI")
		ui_canvas.add_child(projectile)

		print("StingerTower fired projectile at ", current_target.name)

func create_stinger_projectile() -> Projectile:
	var projectile = Projectile.new()

	# Configure projectile for fast, simple attack
	projectile.damage = damage
	projectile.speed = 300.0  # Fast projectile
	projectile.homing_strength = 0.3  # Light homing
	projectile.max_lifetime = 2.0
	projectile.penetration = penetration

	# Set projectile position and target
	if attack_point:
		projectile.global_position = attack_point.global_position
	else:
		projectile.global_position = global_position

	if current_target:
		projectile.set_target(current_target)

	# Visual: Small, red projectile
	projectile.create_stinger_visual()

	return projectile