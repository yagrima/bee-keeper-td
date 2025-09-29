class_name LightningFlowerTower
extends Tower

func _ready():
	super._ready()

	# Configure Lightning Flower Tower stats
	tower_name = "Lightning Flower"
	tower_type = TowerType.OFFENSIVE
	targeting_mode = TargetingMode.WEAKEST  # Target weakest for chain reactions

	# Combat stats - Kettenblitz-Spezialist
	damage = 12.0
	range = 90.0
	attack_speed = 1.5  # Medium-fast attacks
	penetration = 1  # Chain handling is special

	# Costs
	honey_cost = 35
	upgrade_cost = 60

	# Tower level/tier
	level = 1
	tier = "Minor"

	print("LightningFlowerTower initialized: ", tower_name, " with damage: ", damage, " and chain capability")

func get_tower_color() -> Color:
	return Color(0.0, 0.8, 1.0)  # Electric blue for lightning

func execute_attack():
	if not current_target or not is_instance_valid(current_target):
		print("LightningFlowerTower attack cancelled - no valid target")
		return

	# Create chain lightning projectile
	var projectile = create_lightning_projectile()
	if projectile:
		# Add to scene
		var td_scene = get_tree().current_scene
		var ui_canvas = td_scene.get_node("UI")
		ui_canvas.add_child(projectile)

		print("LightningFlowerTower fired chain lightning at ", current_target.name)

func create_lightning_projectile() -> Projectile:
	var projectile = Projectile.new()

	# Configure projectile for chain lightning
	projectile.damage = damage
	projectile.speed = 400.0  # Very fast lightning
	projectile.homing_strength = 0.8  # Strong homing for precise hits
	projectile.max_lifetime = 1.5
	projectile.penetration = penetration

	# Set chain lightning properties
	projectile.chain_count = 2  # Can chain to 2 additional enemies
	projectile.chain_range = 50.0  # Range for chain jumps
	projectile.has_chain_lightning = true

	# Set projectile position and target
	if attack_point:
		projectile.global_position = attack_point.global_position
	else:
		projectile.global_position = global_position

	if current_target:
		projectile.set_target(current_target)

	# Visual: Bright blue lightning projectile
	projectile.create_lightning_visual()

	return projectile