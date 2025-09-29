class_name NectarSprayerTower
extends Tower

func _ready():
	super._ready()

	# Configure Nectar Sprayer Tower stats
	tower_name = "Nectar Sprayer"
	tower_type = TowerType.OFFENSIVE
	targeting_mode = TargetingMode.FARTHEST  # Target farthest for maximum penetration

	# Combat stats - Durchdringungs-Spezialist
	damage = 15.0
	range = 120.0
	attack_speed = 1.2  # Medium speed
	penetration = 3  # Can hit 3 enemies

	# Costs
	honey_cost = 30
	upgrade_cost = 50

	# Tower level/tier
	level = 1
	tier = "Minor"

	print("NectarSprayerTower initialized: ", tower_name, " with damage: ", damage, " and penetration: ", penetration)

func get_tower_color() -> Color:
	return Color(0.9, 0.7, 0.0)  # Golden yellow for nectar

func execute_attack():
	if not current_target or not is_instance_valid(current_target):
		print("NectarSprayerTower attack cancelled - no valid target")
		return

	# Create penetrating projectile
	var projectile = create_nectar_projectile()
	if projectile:
		# Add to scene
		var td_scene = get_tree().current_scene
		var ui_canvas = td_scene.get_node("UI")
		ui_canvas.add_child(projectile)

		print("NectarSprayerTower fired penetrating projectile at ", current_target.name)

func create_nectar_projectile() -> Projectile:
	var projectile = Projectile.new()

	# Configure projectile for penetration
	projectile.damage = damage
	projectile.speed = 200.0  # Medium speed
	projectile.homing_strength = 0.1  # Very light homing to maintain line
	projectile.max_lifetime = 2.5
	projectile.penetration = penetration

	# Set projectile position and target
	if attack_point:
		projectile.global_position = attack_point.global_position
	else:
		projectile.global_position = global_position

	if current_target:
		projectile.set_target(current_target)

	# Visual: Golden, stream-like projectile
	projectile.create_nectar_visual()

	return projectile