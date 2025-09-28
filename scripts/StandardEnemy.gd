class_name StandardEnemy
extends Enemy

func _ready():
	# Set Standard Enemy properties
	enemy_name = "Worker Wasp"
	enemy_type = EnemyType.STANDARD
	max_health = 40.0
	movement_speed = 60.0
	armor = 0.0
	magic_resistance = 0.0

	# Rewards
	honey_reward = 3
	honeygem_reward = 0

	# Special abilities
	can_attack_towers = false

	super._ready()

func setup_visual():
	visual = Node2D.new()
	add_child(visual)

	# Create wasp-like visual
	var body = ColorRect.new()
	body.size = Vector2(12, 8)
	body.position = Vector2(-6, -4)
	body.color = Color(0.9, 0.9, 0.2)  # Yellow body
	visual.add_child(body)

	# Add black stripes
	var stripe1 = ColorRect.new()
	stripe1.size = Vector2(12, 1)
	stripe1.position = Vector2(-6, -2)
	stripe1.color = Color.BLACK
	visual.add_child(stripe1)

	var stripe2 = ColorRect.new()
	stripe2.size = Vector2(12, 1)
	stripe2.position = Vector2(-6, 1)
	stripe2.color = Color.BLACK
	visual.add_child(stripe2)

	# Add simple wings
	var wing1 = ColorRect.new()
	wing1.size = Vector2(4, 6)
	wing1.position = Vector2(-8, -3)
	wing1.color = Color(0.8, 0.8, 0.8, 0.6)  # Semi-transparent wings
	visual.add_child(wing1)

	var wing2 = ColorRect.new()
	wing2.size = Vector2(4, 6)
	wing2.position = Vector2(8, -3)
	wing2.color = Color(0.8, 0.8, 0.8, 0.6)
	visual.add_child(wing2)

func get_enemy_color() -> Color:
	return Color(0.9, 0.9, 0.2)  # Yellow for wasps