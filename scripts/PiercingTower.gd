class_name PiercingTower
extends Tower

# Projectile settings
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 250.0
@export var projectile_color: Color = Color.CYAN

# Audio and effects
var muzzle_flash: Node2D

func _ready():
	tower_name = "Piercing Shooter"
	tower_type = TowerType.OFFENSIVE
	targeting_mode = TargetingMode.NEAREST

	# Stats for Piercing Shooter - less damage but hits multiple enemies
	damage = 10.0
	range = 140.0
	attack_speed = 1.2
	honey_cost = 35
	upgrade_cost = 50
	penetration = 3  # Can hit up to 3 enemies

	super._ready()
	setup_shooter_visual()

func setup_shooter_visual():
	# Update the visual to look more like a piercing tower
	if visual:
		# Clear default visual
		for child in visual.get_children():
			child.queue_free()

		# Create tower base
		var base = ColorRect.new()
		base.size = Vector2(22, 22)
		base.position = Vector2(-11, -11)
		base.color = Color(0.2, 0.4, 0.5)  # Blue-gray base
		visual.add_child(base)

		# Create longer barrel for piercing shots
		var turret = ColorRect.new()
		turret.size = Vector2(20, 4)
		turret.position = Vector2(-10, -2)
		turret.color = Color(0.7, 0.8, 0.9)  # Light blue turret
		visual.add_child(turret)

		# Create muzzle flash (initially hidden)
		muzzle_flash = Node2D.new()
		var flash_rect = ColorRect.new()
		flash_rect.size = Vector2(14, 3)
		flash_rect.position = Vector2(10, -1.5)
		flash_rect.color = Color.CYAN
		flash_rect.modulate.a = 0.0  # Start invisible
		muzzle_flash.add_child(flash_rect)
		visual.add_child(muzzle_flash)

func execute_attack():
	if not current_target or not is_instance_valid(current_target):
		return

	print("PiercingTower executing attack on target: ", current_target.name)
	fire_projectile()
	show_muzzle_flash()

func fire_projectile():
	# Create projectile
	var projectile = Projectile.new()

	# Add projectile to UI layer for visibility
	var td_scene = get_tree().current_scene
	var ui_canvas = td_scene.get_node("UI")
	ui_canvas.add_child(projectile)

	print("Piercing projectile created with penetration: ", penetration)

	# Initialize projectile
	var start_pos = attack_point.global_position
	var target_pos = current_target.global_position

	projectile.initialize(start_pos, target_pos, damage)
	projectile.speed = projectile_speed
	projectile.projectile_color = projectile_color
	projectile.penetration = penetration  # Set penetration from tower

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
	return Color(0.2, 0.6, 0.8)  # Blue for piercing towers

func upgrade():
	super.upgrade()
	# Additional upgrade effects for piercing shooter
	projectile_speed *= 1.1
	penetration += 1  # Gain more penetration on upgrade

	# Change visual based on level
	if level == 2:
		projectile_color = Color.DEEP_SKY_BLUE
	elif level == 3:
		projectile_color = Color.BLUE
	elif level >= 4:
		projectile_color = Color.PURPLE

func get_tower_info() -> Dictionary:
	var info = super.get_tower_info()
	info["projectile_speed"] = projectile_speed
	info["projectile_color"] = str(projectile_color)
	info["penetration"] = penetration
	return info