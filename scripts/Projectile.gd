class_name Projectile
extends Node2D

signal projectile_hit(target, damage)
signal projectile_expired

enum ProjectileType {
	BULLET,
	MISSILE,
	LASER,
	EXPLOSIVE
}

# Projectile Properties
@export var projectile_type: ProjectileType = ProjectileType.BULLET
@export var damage: float = 10.0
@export var speed: float = 300.0
@export var max_range: float = 200.0
@export var penetration: int = 1  # How many enemies it can hit
@export var splash_radius: float = 0.0  # 0 = no splash damage

# Homing properties
@export var is_homing: bool = false
@export var turn_rate: float = 5.0  # radians per second

# Visual
@export var trail_enabled: bool = false
@export var projectile_color: Color = Color.YELLOW

# Internal state
var target: Node2D = null
var start_position: Vector2
var velocity: Vector2
var traveled_distance: float = 0.0
var hits_remaining: int
var has_hit_targets: Array[Node2D] = []

# Components
var visual: Node2D
var collision_area: Area2D

func _ready():
	hits_remaining = penetration
	start_position = global_position
	setup_visual()
	setup_collision()

func setup_visual():
	visual = Node2D.new()
	add_child(visual)

	# Simple projectile visual
	var rect = ColorRect.new()
	rect.size = Vector2(8, 4)
	rect.position = Vector2(-4, -2)
	rect.color = projectile_color
	visual.add_child(rect)

func setup_collision():
	collision_area = Area2D.new()
	add_child(collision_area)

	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(8, 4)
	collision_shape.shape = rect_shape
	collision_area.add_child(collision_shape)

	collision_area.body_entered.connect(_on_collision_body_entered)
	collision_area.area_entered.connect(_on_collision_area_entered)

func initialize(start_pos: Vector2, target_pos: Vector2, projectile_damage: float):
	global_position = start_pos
	damage = projectile_damage
	start_position = start_pos

	# Calculate initial velocity
	var direction = start_pos.direction_to(target_pos)
	velocity = direction * speed
	rotation = direction.angle()

func initialize_with_target(start_pos: Vector2, target_node: Node2D, projectile_damage: float):
	target = target_node
	initialize(start_pos, target_node.global_position, projectile_damage)

func _process(delta):
	update_movement(delta)
	update_visual()
	check_range_and_lifetime()

func update_movement(delta):
	if is_homing and target and is_instance_valid(target):
		update_homing_movement(delta)
	else:
		# Straight line movement
		global_position += velocity * delta
		traveled_distance += velocity.length() * delta

func update_homing_movement(delta):
	if not target or not is_instance_valid(target):
		is_homing = false
		return

	var target_direction = global_position.direction_to(target.global_position)
	var current_direction = velocity.normalized()

	# Smoothly turn towards target
	var angle_diff = current_direction.angle_to(target_direction)
	var max_turn = turn_rate * delta

	if abs(angle_diff) <= max_turn:
		velocity = target_direction * speed
	else:
		var turn_direction = sign(angle_diff)
		var new_angle = current_direction.angle() + turn_direction * max_turn
		velocity = Vector2.from_angle(new_angle) * speed

	global_position += velocity * delta
	traveled_distance += velocity.length() * delta

func update_visual():
	if velocity.length() > 0:
		visual.rotation = velocity.angle()

func check_range_and_lifetime():
	if traveled_distance >= max_range:
		expire()

func _on_collision_body_entered(body):
	handle_collision(body)

func _on_collision_area_entered(area):
	var body = area.get_parent()
	handle_collision(body)

func handle_collision(body):
	if not body.has_method("take_damage"):
		return

	if body in has_hit_targets:
		return  # Already hit this target

	# Deal damage
	body.take_damage(damage)
	has_hit_targets.append(body)
	projectile_hit.emit(body, damage)

	# Handle splash damage
	if splash_radius > 0:
		deal_splash_damage()

	# Reduce penetration
	hits_remaining -= 1
	if hits_remaining <= 0:
		destroy()

func deal_splash_damage():
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var circle = CircleShape2D.new()
	circle.radius = splash_radius
	query.shape = circle
	query.transform = Transform2D(0, global_position)

	var results = space_state.intersect_shape(query)

	for result in results:
		var body = result["collider"]
		if body.has_method("take_damage") and body not in has_hit_targets:
			var splash_damage = damage * 0.5  # 50% splash damage
			body.take_damage(splash_damage)
			projectile_hit.emit(body, splash_damage)

func expire():
	projectile_expired.emit()
	destroy()

func destroy():
	queue_free()

func get_projectile_info() -> Dictionary:
	return {
		"type": ProjectileType.keys()[projectile_type],
		"damage": damage,
		"speed": speed,
		"range": max_range,
		"penetration": penetration,
		"splash_radius": splash_radius,
		"is_homing": is_homing
	}