class_name BasicShooterTower
extends Tower

# Projectile settings
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 300.0
@export var projectile_color: Color = Color.YELLOW

# Audio and effects
var muzzle_flash: Node2D

func _ready():
	tower_name = "Basic Shooter"
	tower_type = TowerType.OFFENSIVE
	targeting_mode = TargetingMode.NEAREST

	# Default stats for Basic Shooter
	damage = 15.0
	range = 120.0
	attack_speed = 1.5
	honey_cost = 25
	upgrade_cost = 40

	super._ready()
	setup_shooter_visual()

func setup_shooter_visual():
	# Update the visual to look more like a shooter tower
	if visual:
		# Clear default visual
		for child in visual.get_children():
			child.queue_free()

		# Create tower base
		var base = ColorRect.new()
		base.size = Vector2(20, 20)
		base.position = Vector2(-10, -10)
		base.color = Color(0.4, 0.3, 0.2)  # Brown base
		visual.add_child(base)

		# Create turret/cannon
		var turret = ColorRect.new()
		turret.size = Vector2(16, 6)
		turret.position = Vector2(-8, -3)
		turret.color = Color(0.6, 0.6, 0.6)  # Gray turret
		visual.add_child(turret)

		# Create muzzle flash (initially hidden)
		muzzle_flash = Node2D.new()
		var flash_rect = ColorRect.new()
		flash_rect.size = Vector2(12, 4)
		flash_rect.position = Vector2(8, -2)
		flash_rect.color = Color.YELLOW
		flash_rect.modulate.a = 0.0  # Start invisible
		muzzle_flash.add_child(flash_rect)
		visual.add_child(muzzle_flash)

func execute_attack():
	if not current_target or not is_instance_valid(current_target):
		return

	fire_projectile()
	show_muzzle_flash()

func fire_projectile():
	# Create projectile
	var projectile = Projectile.new()
	get_tree().current_scene.add_child(projectile)

	# Initialize projectile
	var start_pos = attack_point.global_position
	var target_pos = current_target.global_position

	projectile.initialize(start_pos, target_pos, damage)
	projectile.speed = projectile_speed
	projectile.projectile_color = projectile_color

	# Connect signals for feedback
	projectile.projectile_hit.connect(_on_projectile_hit)
	projectile.projectile_expired.connect(_on_projectile_expired)

func show_muzzle_flash():
	if muzzle_flash:
		# Quick muzzle flash effect
		var flash_rect = muzzle_flash.get_child(0)
		flash_rect.modulate.a = 1.0

		# Fade out the flash
		var tween = create_tween()
		tween.tween_property(flash_rect, "modulate:a", 0.0, 0.1)

func _on_projectile_hit(target_hit, damage_dealt):
	# Could add hit effects, sound, etc.
	print(tower_name + " hit " + str(target_hit) + " for " + str(damage_dealt) + " damage")

func _on_projectile_expired():
	# Could add miss effects, etc.
	pass

func get_tower_color() -> Color:
	return Color(0.8, 0.4, 0.2)  # Orange-brown for shooter towers

func upgrade():
	super.upgrade()
	# Additional upgrade effects for shooter
	projectile_speed *= 1.1

	# Change visual based on level
	if level == 2:
		projectile_color = Color.ORANGE
	elif level == 3:
		projectile_color = Color.RED
	elif level >= 4:
		projectile_color = Color.PURPLE

func get_tower_info() -> Dictionary:
	var info = super.get_tower_info()
	info["projectile_speed"] = projectile_speed
	info["projectile_color"] = str(projectile_color)
	return info