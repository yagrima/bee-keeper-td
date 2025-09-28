class_name Enemy
extends CharacterBody2D

signal enemy_died(enemy, reward)
signal enemy_reached_end(enemy, damage)
signal enemy_took_damage(enemy, damage, remaining_health)

enum EnemyType {
	STANDARD,
	BRUISER,
	HORDE,
	LEADER,
	SUPPORT,
	SUMMONER,
	MINION,
	SKULK,
	SOLO
}

enum EnemyState {
	MOVING,
	ATTACKING,
	STUNNED,
	DEAD
}

# Enemy Properties
@export var enemy_name: String = "Standard Enemy"
@export var enemy_type: EnemyType = EnemyType.STANDARD
@export var max_health: float = 50.0
@export var movement_speed: float = 80.0
@export var armor: float = 0.0
@export var magic_resistance: float = 0.0

# Rewards
@export var honey_reward: int = 5
@export var honeygem_reward: int = 0

# Special abilities
@export var can_attack_towers: bool = false
@export var attack_damage: float = 0.0
@export var attack_range: float = 0.0

# Internal state
var current_health: float
var current_state: EnemyState = EnemyState.MOVING
var path_points: Array[Vector2] = []
var current_path_index: int = 0
var path_progress: float = 0.0

# Status effects
var is_slowed: bool = false
var slow_factor: float = 1.0
var is_stunned: bool = false
var stun_duration: float = 0.0

# Components
@onready var visual: Node2D
@onready var health_bar: ProgressBar
@onready var collision_area: Area2D

func _ready():
	current_health = max_health
	setup_visual()
	setup_collision()
	setup_health_bar()

func setup_visual():
	visual = Node2D.new()
	add_child(visual)

	# Create basic enemy visual
	var sprite = ColorRect.new()
	sprite.size = Vector2(16, 16)
	sprite.position = Vector2(-8, -8)
	sprite.color = get_enemy_color()
	visual.add_child(sprite)

func setup_collision():
	collision_area = Area2D.new()
	add_child(collision_area)

	var collision_shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(16, 16)
	collision_shape.shape = rect_shape
	collision_area.add_child(collision_shape)

	# Set collision layers for tower targeting
	collision_area.collision_layer = 2  # Enemy layer
	collision_area.collision_mask = 1   # Can be detected by towers

func setup_health_bar():
	health_bar = ProgressBar.new()
	health_bar.size = Vector2(20, 4)
	health_bar.position = Vector2(-10, -14)
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_bar.show_percentage = false

	# Style the health bar
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color.RED
	health_bar.add_theme_stylebox_override("fill", style_box)

	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color.DARK_GRAY
	health_bar.add_theme_stylebox_override("background", bg_style)

	add_child(health_bar)

func get_enemy_color() -> Color:
	match enemy_type:
		EnemyType.STANDARD:
			return Color.WHITE
		EnemyType.BRUISER:
			return Color.ORANGE_RED
		EnemyType.HORDE:
			return Color.LIGHT_BLUE
		EnemyType.LEADER:
			return Color.PURPLE
		EnemyType.SUPPORT:
			return Color.YELLOW
		EnemyType.SUMMONER:
			return Color.DARK_MAGENTA
		EnemyType.MINION:
			return Color.LIGHT_GRAY
		EnemyType.SKULK:
			return Color.DARK_GREEN
		EnemyType.SOLO:
			return Color.CRIMSON
		_:
			return Color.WHITE

func _physics_process(delta):
	if current_state == EnemyState.DEAD:
		return

	update_status_effects(delta)

	match current_state:
		EnemyState.MOVING:
			update_movement(delta)
		EnemyState.ATTACKING:
			update_combat(delta)
		EnemyState.STUNNED:
			pass  # Can't move while stunned

func update_status_effects(delta):
	if is_stunned:
		stun_duration -= delta
		if stun_duration <= 0:
			is_stunned = false
			current_state = EnemyState.MOVING

func update_movement(delta):
	if path_points.is_empty() or current_path_index >= path_points.size():
		reach_end()
		return

	var current_speed = movement_speed * slow_factor
	move_along_path(delta, current_speed)

func move_along_path(delta, speed):
	if current_path_index >= path_points.size() - 1:
		reach_end()
		return

	var start_point = path_points[current_path_index]
	var end_point = path_points[current_path_index + 1]
	var segment_length = start_point.distance_to(end_point)

	if segment_length == 0:
		current_path_index += 1
		return

	# Move along current segment
	var move_distance = speed * delta
	path_progress += move_distance / segment_length

	if path_progress >= 1.0:
		# Reached next waypoint
		current_path_index += 1
		path_progress = 0.0

		if current_path_index < path_points.size():
			global_position = path_points[current_path_index]
	else:
		# Interpolate position along segment
		global_position = start_point.lerp(end_point, path_progress)

	# Rotate to face movement direction
	if end_point != start_point:
		var direction = start_point.direction_to(end_point)
		visual.rotation = direction.angle()

func update_combat(delta):
	# TODO: Implement tower attacking for Bruiser enemies
	pass

func set_path(new_path: Array[Vector2]):
	path_points = new_path
	current_path_index = 0
	path_progress = 0.0

	if not path_points.is_empty():
		global_position = path_points[0]

func take_damage(damage: float, damage_type: String = "physical"):
	if current_state == EnemyState.DEAD:
		return

	var actual_damage = calculate_damage(damage, damage_type)
	current_health -= actual_damage

	# Update health bar
	health_bar.value = current_health

	# Emit damage signal
	enemy_took_damage.emit(self, actual_damage, current_health)

	# Show damage number
	show_damage_number(actual_damage)

	if current_health <= 0:
		die()

func calculate_damage(damage: float, damage_type: String) -> float:
	match damage_type:
		"physical":
			return max(1, damage - armor)
		"magic":
			return damage * (1.0 - magic_resistance / 100.0)
		"true":
			return damage
		_:
			return damage

func show_damage_number(damage: float):
	var damage_label = Label.new()
	damage_label.text = str(int(damage))
	damage_label.position = Vector2(-10, -25)
	damage_label.add_theme_color_override("font_color", Color.RED)
	add_child(damage_label)

	# Animate damage number
	var tween = create_tween()
	tween.parallel().tween_property(damage_label, "position:y", -35, 0.5)
	tween.parallel().tween_property(damage_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(damage_label.queue_free)

func apply_slow(factor: float, duration: float):
	is_slowed = true
	slow_factor = factor

	# Remove slow after duration
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(_remove_slow)

func _remove_slow():
	is_slowed = false
	slow_factor = 1.0

func apply_stun(duration: float):
	is_stunned = true
	stun_duration = duration
	current_state = EnemyState.STUNNED

func die():
	current_state = EnemyState.DEAD

	# Give rewards
	GameManager.add_resource("honey", honey_reward)
	if honeygem_reward > 0:
		GameManager.add_resource("honeygems", honeygem_reward)

	# Emit death signal
	enemy_died.emit(self, {"honey": honey_reward, "honeygems": honeygem_reward})

	# Death animation
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

func reach_end():
	var damage_to_player = get_player_damage()
	enemy_reached_end.emit(self, damage_to_player)
	queue_free()

func get_player_damage() -> int:
	# Different enemy types deal different damage
	match enemy_type:
		EnemyType.SOLO:
			return 20  # Boss enemies deal max damage
		EnemyType.BRUISER:
			return 3
		EnemyType.LEADER:
			return 2
		_:
			return 1

func get_enemy_info() -> Dictionary:
	return {
		"name": enemy_name,
		"type": EnemyType.keys()[enemy_type],
		"health": current_health,
		"max_health": max_health,
		"speed": movement_speed,
		"armor": armor,
		"magic_resistance": magic_resistance,
		"honey_reward": honey_reward,
		"honeygem_reward": honeygem_reward
	}