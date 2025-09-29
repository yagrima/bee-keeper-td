class_name PropolisBomberTower
extends Tower

func _ready():
	super._ready()

	# Configure Propolis Bomber Tower stats
	tower_name = "Propolis Bomber"
	tower_type = TowerType.OFFENSIVE
	targeting_mode = TargetingMode.STRONGEST  # Target highest HP enemies

	# Combat stats - Explosions-Spezialist
	damage = 35.0
	range = 100.0
	attack_speed = 0.8  # Slow but powerful
	penetration = 1  # Explosion handles multiple targets

	# Costs
	honey_cost = 45
	upgrade_cost = 75

	# Tower level/tier
	level = 1
	tier = "Minor"

	print("PropolisBomberTower initialized: ", tower_name, " with damage: ", damage, " and attack speed: ", attack_speed)

func get_tower_color() -> Color:
	return Color(0.4, 0.2, 0.0)  # Dark brown for propolis

func execute_attack():
	if not current_target or not is_instance_valid(current_target):
		print("PropolisBomberTower attack cancelled - no valid target")
		return

	# Create explosive projectile
	var projectile = create_propolis_projectile()
	if projectile:
		# Add to scene
		var td_scene = get_tree().current_scene
		var ui_canvas = td_scene.get_node("UI")
		ui_canvas.add_child(projectile)

		print("PropolisBomberTower fired explosive projectile at ", current_target.name)

func create_propolis_projectile() -> Projectile:
	var projectile = Projectile.new()

	# Configure projectile for explosive attack
	projectile.damage = damage
	projectile.speed = 150.0  # Slower projectile
	projectile.homing_strength = 0.2  # Less homing for balance
	projectile.max_lifetime = 3.0
	projectile.penetration = penetration

	# Set explosion properties
	projectile.explosion_radius = 40.0
	projectile.has_explosion = true

	# Set projectile position and target
	if attack_point:
		projectile.global_position = attack_point.global_position
	else:
		projectile.global_position = global_position

	if current_target:
		projectile.set_target(current_target)

	# Visual: Large, brown projectile
	projectile.create_propolis_visual()

	return projectile