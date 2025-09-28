class_name WaveManager
extends Node

signal wave_started(wave_number)
signal wave_completed(wave_number, enemies_killed)
signal enemy_spawned(enemy)
signal all_waves_completed

# Wave configuration
@export var spawn_point: Vector2
@export var enemy_path: Array[Vector2] = []

# Wave state
var current_wave: int = 0
var is_wave_active: bool = false
var enemies_in_wave: Array[Enemy] = []
var enemies_spawned: int = 0
var enemies_killed: int = 0

# Spawning
var spawn_timer: float = 0.0
var spawn_interval: float = 1.0

# Wave definitions
var wave_definitions: Array[Dictionary] = []

func _ready():
	setup_wave_definitions()

func _process(delta):
	if is_wave_active:
		update_spawning(delta)
		check_wave_completion()

func setup_wave_definitions():
	# Define waves with increasing difficulty
	wave_definitions = [
		{
			"wave": 1,
			"enemies": [
				{"type": "standard", "count": 5, "interval": 1.5}
			]
		},
		{
			"wave": 2,
			"enemies": [
				{"type": "standard", "count": 8, "interval": 1.2}
			]
		},
		{
			"wave": 3,
			"enemies": [
				{"type": "standard", "count": 6, "interval": 1.0},
				{"type": "standard", "count": 3, "interval": 0.8}
			]
		},
		{
			"wave": 4,
			"enemies": [
				{"type": "standard", "count": 10, "interval": 1.0}
			]
		},
		{
			"wave": 5,
			"enemies": [
				{"type": "standard", "count": 12, "interval": 0.8}
			]
		}
	]

func start_wave(wave_number: int):
	if is_wave_active:
		print("Wave already active!")
		return

	if wave_number > wave_definitions.size():
		print("All waves completed!")
		all_waves_completed.emit()
		return

	current_wave = wave_number
	is_wave_active = true
	enemies_spawned = 0
	enemies_killed = 0
	enemies_in_wave.clear()

	var wave_data = wave_definitions[wave_number - 1]
	setup_current_wave(wave_data)

	wave_started.emit(current_wave)
	print("Starting wave ", current_wave)

func setup_current_wave(wave_data: Dictionary):
	# For now, we'll spawn all enemy types in sequence
	# Later this can be improved for simultaneous spawning
	var first_enemy_group = wave_data["enemies"][0]
	spawn_interval = first_enemy_group["interval"]

func update_spawning(delta):
	if not is_wave_active:
		return

	spawn_timer -= delta

	if spawn_timer <= 0:
		spawn_next_enemy()

func spawn_next_enemy():
	var wave_data = wave_definitions[current_wave - 1]
	var total_enemies = 0

	# Calculate total enemies in wave
	for enemy_group in wave_data["enemies"]:
		total_enemies += enemy_group["count"]

	if enemies_spawned >= total_enemies:
		return  # All enemies spawned

	# Find which enemy group we're currently spawning
	var current_group_index = 0
	var enemies_spawned_so_far = 0

	for i in range(wave_data["enemies"].size()):
		var group = wave_data["enemies"][i]
		if enemies_spawned < enemies_spawned_so_far + group["count"]:
			current_group_index = i
			break
		enemies_spawned_so_far += group["count"]

	var current_group = wave_data["enemies"][current_group_index]
	var enemy_type = current_group["type"]

	# Spawn enemy
	var enemy = create_enemy(enemy_type)
	if enemy:
		enemies_spawned += 1
		spawn_timer = current_group["interval"]

func create_enemy(enemy_type: String) -> Enemy:
	var enemy: Enemy = null

	match enemy_type:
		"standard":
			enemy = StandardEnemy.new()
		_:
			print("Unknown enemy type: ", enemy_type)
			return null

	# Set up enemy
	enemy.global_position = spawn_point
	enemy.set_path(enemy_path)

	# Connect signals
	enemy.enemy_died.connect(_on_enemy_died)
	enemy.enemy_reached_end.connect(_on_enemy_reached_end)

	# Add to scene
	get_tree().current_scene.add_child(enemy)
	enemies_in_wave.append(enemy)

	enemy_spawned.emit(enemy)
	print("Spawned ", enemy_type, " enemy")

	return enemy

func check_wave_completion():
	if not is_wave_active:
		return

	var wave_data = wave_definitions[current_wave - 1]
	var total_enemies = 0

	for enemy_group in wave_data["enemies"]:
		total_enemies += enemy_group["count"]

	# Check if all enemies are spawned and dealt with
	if enemies_spawned >= total_enemies and enemies_in_wave.is_empty():
		complete_wave()

func complete_wave():
	is_wave_active = false
	wave_completed.emit(current_wave, enemies_killed)
	print("Wave ", current_wave, " completed! Enemies killed: ", enemies_killed)

func _on_enemy_died(enemy: Enemy, rewards: Dictionary):
	if enemy in enemies_in_wave:
		enemies_in_wave.erase(enemy)
		enemies_killed += 1

func _on_enemy_reached_end(enemy: Enemy, damage: int):
	if enemy in enemies_in_wave:
		enemies_in_wave.erase(enemy)

	# Notify the game that player took damage
	var td_scene = get_tree().current_scene
	if td_scene.has_method("take_damage"):
		td_scene.take_damage(damage)

func set_spawn_point(point: Vector2):
	spawn_point = point

func set_enemy_path(path: Array[Vector2]):
	enemy_path = path

func get_current_wave() -> int:
	return current_wave

func get_wave_progress() -> Dictionary:
	if not is_wave_active:
		return {"spawned": 0, "total": 0, "killed": enemies_killed}

	var wave_data = wave_definitions[current_wave - 1]
	var total_enemies = 0

	for enemy_group in wave_data["enemies"]:
		total_enemies += enemy_group["count"]

	return {
		"spawned": enemies_spawned,
		"total": total_enemies,
		"killed": enemies_killed,
		"remaining": enemies_in_wave.size()
	}

func get_total_waves() -> int:
	return wave_definitions.size()

func is_wave_in_progress() -> bool:
	return is_wave_active