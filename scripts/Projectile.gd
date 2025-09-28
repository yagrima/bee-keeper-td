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
@export var speed: float = 600.0
@export var max_range: float = 200.0
@export var penetration: int = 1  # How many enemies it can hit
@export var splash_radius: float = 0.0  # 0 = no splash damage

# Homing properties
@export var is_homing: bool = false  # Default: no homing, can be enabled per tower
@export var turn_rate: float = 8.0  # Turn rate for homing projectiles

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
var homing_timeout: float = 0.0
var max_homing_time: float = 3.0  # Stop homing after 3 seconds

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

	# Set collision layers for projectile detection
	collision_area.collision_layer = 4  # Projectile layer
	collision_area.collision_mask = 2   # Detect enemy layer

	collision_area.body_entered.connect(_on_collision_body_entered)
	collision_area.area_entered.connect(_on_collision_area_entered)  # Enemies are Area2D!


func initialize(start_pos: Vector2, target_pos: Vector2, projectile_damage: float):
	global_position = start_pos
	damage = projectile_damage
	start_position = start_pos
	hits_remaining = penetration  # Reset hits based on current penetration

	# Calculate initial velocity with speed boost for fast mode
	var current_speed = speed
	if Engine.time_scale > 1.0:
		current_speed *= Engine.time_scale * 1.25  # 1.25x speed multiplier per time_scale
		max_range *= 1.5  # Increase range in fast mode
	
	var direction = start_pos.direction_to(target_pos)
	velocity = direction * current_speed
	rotation = direction.angle()

func initialize_with_target(start_pos: Vector2, target_node: Node2D, projectile_damage: float):
	target = target_node
	initialize(start_pos, target_node.global_position, projectile_damage)
	
	# Ensure homing is enabled for fast mode
	if Engine.time_scale > 1.0:
		is_homing = true

func _process(delta):
	update_movement(delta)
	update_visual()
	check_range_and_lifetime()
	
	# Enhanced collision detection for high speeds
	if Engine.time_scale > 1.0:
		# Check collisions multiple times per frame for high speeds
		for i in range(int(Engine.time_scale)):
			check_manual_collisions()
	else:
		check_manual_collisions()

func update_movement(delta):
	# Cap delta to prevent issues with high time scales (10x speed)
	var capped_delta = min(delta, 1.0 / 60.0)  # Cap at 60 FPS equivalent
	
	if is_homing and target and is_instance_valid(target):
		update_homing_movement(capped_delta)
	else:
		# Straight line movement
		global_position += velocity * capped_delta
		traveled_distance += velocity.length() * capped_delta

func update_homing_movement(delta):
	if not target or not is_instance_valid(target):
		is_homing = false
		return

	# Cap delta to prevent issues with high time scales (10x speed)
	var capped_delta = min(delta, 1.0 / 60.0)  # Cap at 60 FPS equivalent
	
	# Check homing timeout
	homing_timeout += capped_delta
	if homing_timeout >= max_homing_time:
		is_homing = false
		print("Projectile homing timeout - switching to straight line")
		return
	
	# Calculate current speed (with speed boost for fast mode)
	var current_speed = speed
	if Engine.time_scale > 1.0:
		current_speed *= Engine.time_scale * 1.25  # 1.25x speed multiplier per time_scale
	
	# Enhanced turn rate for high speeds
	var effective_turn_rate = turn_rate
	if Engine.time_scale > 1.0:
		effective_turn_rate *= Engine.time_scale  # Proportional turn rate increase
	
	var target_direction = global_position.direction_to(target.global_position)
	var current_direction = velocity.normalized()

	# Smoothly turn towards target
	var angle_diff = current_direction.angle_to(target_direction)
	var max_turn = effective_turn_rate * capped_delta

	if abs(angle_diff) <= max_turn:
		velocity = target_direction * current_speed
	else:
		var turn_direction = sign(angle_diff)
		var new_angle = current_direction.angle() + turn_direction * max_turn
		velocity = Vector2.from_angle(new_angle) * current_speed

	global_position += velocity * capped_delta
	traveled_distance += velocity.length() * capped_delta

func update_visual():
	if velocity.length() > 0:
		visual.rotation = velocity.angle()

func check_range_and_lifetime():
	if traveled_distance >= max_range:
		expire()

func check_manual_collisions():
	# Enhanced collision detection for high time scales (10x speed)
	var space_state = get_world_2d().direct_space_state
	
	# Check multiple points around the projectile for better collision detection
	var check_positions = [
		global_position,
		global_position + Vector2(2, 0),
		global_position + Vector2(-2, 0),
		global_position + Vector2(0, 2),
		global_position + Vector2(0, -2),
		global_position + Vector2(1, 1),
		global_position + Vector2(-1, -1),
		global_position + Vector2(1, -1),
		global_position + Vector2(-1, 1)
	]
	
	for pos in check_positions:
		var query = PhysicsPointQueryParameters2D.new()
		query.position = pos
		query.collision_mask = 2  # Enemy layer
		query.collide_with_areas = true  # Important for Area2D enemies
		query.collide_with_bodies = true
		
		var result = space_state.intersect_point(query)
		if result.size() > 0:
			for hit in result:
				var body = hit.collider
				if body and body.has_method("take_damage"):
					handle_collision(body)
					return  # Stop after first collision


func _on_collision_body_entered(body):
	handle_collision(body)

func _on_collision_area_entered(area):
	# The enemy IS the Area2D, not its parent
	handle_collision(area)

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