class_name Tower
extends Node2D

signal tower_destroyed
signal tower_upgraded
signal target_acquired(target)
signal target_lost

enum TowerType {
	OFFENSIVE,
	DEFENSIVE,
	SUPPORTIVE
}

enum TargetingMode {
	NEAREST,
	FARTHEST,
	STRONGEST,
	WEAKEST,
	FIRST,
	LAST
}

# Tower Properties
@export var tower_name: String = "Basic Tower"
@export var tower_type: TowerType = TowerType.OFFENSIVE
@export var targeting_mode: TargetingMode = TargetingMode.NEAREST

# Combat Stats
@export var damage: float = 10.0
@export var range: float = 100.0
@export var attack_speed: float = 1.0  # attacks per second
@export var penetration: int = 1  # how many enemies projectile can hit

# Costs
@export var honey_cost: int = 25
@export var upgrade_cost: int = 50

# Tower Level/Tier
@export var level: int = 1
@export var tier: String = "Minor"  # Minor, Normal, Enhanced, etc.

# Internal state
var current_target: Node2D = null
var enemies_in_range: Array[Node2D] = []
var attack_timer: float = 0.0
var is_attacking: bool = false

# Components
@onready var range_area: Area2D
@onready var visual: Node2D
@onready var attack_point: Marker2D

func _ready():
	setup_tower()
	setup_range_detection()

func setup_tower():
	# Create visual representation
	visual = Node2D.new()
	add_child(visual)

	var sprite = ColorRect.new()
	sprite.size = Vector2(24, 24)
	sprite.position = Vector2(-12, -12)
	sprite.color = get_tower_color()
	visual.add_child(sprite)

	# Create attack point
	attack_point = Marker2D.new()
	attack_point.position = Vector2(0, -12)
	add_child(attack_point)

func setup_range_detection():
	# Create range detection area
	range_area = Area2D.new()
	add_child(range_area)

	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = range
	collision_shape.shape = circle_shape
	range_area.add_child(collision_shape)

	# Set collision layers to detect enemies
	range_area.collision_layer = 1  # Tower layer
	range_area.collision_mask = 2   # Detect enemy layer

	# Connect signals
	range_area.body_entered.connect(_on_enemy_entered_range)
	range_area.body_exited.connect(_on_enemy_exited_range)
	range_area.area_entered.connect(_on_enemy_entered_range)
	range_area.area_exited.connect(_on_enemy_exited_range)

	print("Tower range detection setup with radius: ", range)

func get_tower_color() -> Color:
	match tower_type:
		TowerType.OFFENSIVE:
			return Color.RED
		TowerType.DEFENSIVE:
			return Color.BLUE
		TowerType.SUPPORTIVE:
			return Color.YELLOW
		_:
			return Color.WHITE

func _process(delta):
	update_targeting()
	update_attack_timer(delta)
	update_visual()

func update_targeting():
	# Remove dead/invalid enemies
	enemies_in_range = enemies_in_range.filter(func(enemy): return is_instance_valid(enemy))

	# Find target based on targeting mode
	if enemies_in_range.is_empty():
		if current_target:
			current_target = null
			target_lost.emit()
		return

	var new_target = find_best_target()
	if new_target != current_target:
		current_target = new_target
		if current_target:
			target_acquired.emit(current_target)

func find_best_target() -> Node2D:
	if enemies_in_range.is_empty():
		return null

	match targeting_mode:
		TargetingMode.NEAREST:
			return find_nearest_enemy()
		TargetingMode.FARTHEST:
			return find_farthest_enemy()
		TargetingMode.FIRST:
			return enemies_in_range[0]
		_:
			return enemies_in_range[0]

func find_nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var nearest_distance: float = INF

	for enemy in enemies_in_range:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = enemy

	return nearest

func find_farthest_enemy() -> Node2D:
	var farthest: Node2D = null
	var farthest_distance: float = 0.0

	for enemy in enemies_in_range:
		var distance = global_position.distance_to(enemy.global_position)
		if distance > farthest_distance:
			farthest_distance = distance
			farthest = enemy

	return farthest

func update_attack_timer(delta):
	if attack_timer > 0:
		attack_timer -= delta

	if current_target and attack_timer <= 0:
		perform_attack()

func perform_attack():
	if not current_target or not is_instance_valid(current_target):
		print("Tower attack cancelled - no valid target")
		return

	# Reset attack timer
	attack_timer = 1.0 / attack_speed

	print("Tower ", tower_name, " performing attack on ", current_target.name)

	# Perform the actual attack (override in derived classes)
	execute_attack()

func execute_attack():
	# Base implementation - override in derived classes
	print("Base execute_attack() called - should be overridden")
	print(tower_name + " attacks " + str(current_target))

func update_visual():
	if current_target:
		# Rotate towards target
		var direction = global_position.direction_to(current_target.global_position)
		visual.rotation = direction.angle() + PI/2

func _on_enemy_entered_range(body):
	print("Tower detected something entering range: ", body.name if body else "null")
	if body.has_method("take_damage"):  # Check if it's an enemy
		if body not in enemies_in_range:
			enemies_in_range.append(body)
			print("Enemy added to range: ", enemies_in_range.size(), " enemies in range")

func _on_enemy_exited_range(body):
	print("Tower detected something exiting range: ", body.name if body else "null")
	if body in enemies_in_range:
		enemies_in_range.erase(body)
		print("Enemy removed from range: ", enemies_in_range.size(), " enemies in range")

func upgrade():
	if can_upgrade():
		level += 1
		damage *= 1.2
		range *= 1.1
		attack_speed *= 1.1
		update_range_visual()
		tower_upgraded.emit()

func can_upgrade() -> bool:
	return GameManager.get_resource("honey") >= upgrade_cost

func get_upgrade_cost() -> int:
	return upgrade_cost * level

func destroy():
	tower_destroyed.emit()
	queue_free()

func update_range_visual():
	if range_area and range_area.get_child(0):
		var collision_shape = range_area.get_child(0) as CollisionShape2D
		var circle_shape = collision_shape.shape as CircleShape2D
		circle_shape.radius = range

func get_tower_info() -> Dictionary:
	return {
		"name": tower_name,
		"type": TowerType.keys()[tower_type],
		"level": level,
		"tier": tier,
		"damage": damage,
		"range": range,
		"attack_speed": attack_speed,
		"cost": honey_cost,
		"upgrade_cost": get_upgrade_cost()
	}