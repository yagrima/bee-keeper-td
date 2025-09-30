class_name TDWaveController
extends Node

## Wave controller for TowerDefense scene
## Manages wave progression, auto-wave timing, and countdown displays

# Reference to the main TowerDefense scene
var td_scene: Node2D

# Constructor to receive the TowerDefense scene reference
func _init(p_td_scene: Node2D):
	td_scene = p_td_scene

# =============================================================================
# WAVE EVENT HANDLERS
# =============================================================================

func _on_wave_started(wave_number: int):
	print("Wave ", wave_number, " started!")
	td_scene.update_ui()  # Update UI to show current wave composition

	# Start a timer to update wave composition in real-time
	start_wave_composition_timer()

func _on_wave_completed(wave_number: int, enemies_killed: int):
	print("Wave ", wave_number, " completed! Killed ", enemies_killed, " enemies")
	td_scene.current_wave += 1

	# Auto-save after each wave
	td_scene.auto_save_game("Wave %d completed" % wave_number)

	# Check if all waves are completed
	if td_scene.current_wave > 5:
		_on_all_waves_completed()
		return

	# Stop the wave composition timer
	stop_wave_composition_timer()

	# Start automatic next wave after delay based on speed mode
	start_automatic_next_wave()

	td_scene.update_ui()  # Update UI for next wave

func _on_enemy_spawned(enemy: Enemy):
	print("Enemy spawned: ", enemy.enemy_name)

func _on_all_waves_completed():
	print("All waves completed! Victory!")

	# Auto-save after completing all waves
	td_scene.auto_save_game("All waves completed - Victory!")

	# Stop the wave composition timer
	stop_wave_composition_timer()

	# Stop any auto wave timer
	stop_auto_wave_timer()

	# Delay victory screen by 0.01 seconds to allow last enemy to despawn
	var timer = td_scene.get_tree().create_timer(0.01)
	timer.timeout.connect(td_scene.show_victory_screen)

# =============================================================================
# AUTOMATIC WAVE PROGRESSION
# =============================================================================

func start_automatic_next_wave():
	"""Start the next wave automatically after a delay based on speed mode"""
	var delay_seconds = get_wave_delay_for_speed_mode()

	print("Starting automatic next wave in %.1f seconds (speed mode: %d)" % [delay_seconds, td_scene.speed_mode])

	# Set countdown and start visual countdown
	td_scene.countdown_seconds = delay_seconds
	start_wave_countdown_display()

	# Create and start timer for automatic wave start
	var timer = Timer.new()
	timer.name = "AutoWaveTimer"
	timer.wait_time = delay_seconds
	timer.one_shot = true
	timer.timeout.connect(_on_auto_wave_timer_timeout)
	td_scene.add_child(timer)
	timer.start()

	# Update UI to show countdown
	update_wave_countdown_ui(delay_seconds)

func get_wave_delay_for_speed_mode() -> float:
	"""Get the delay in seconds for the next wave based on current speed mode"""
	match td_scene.speed_mode:
		0:  # Normal speed (1x)
			return 15.0
		1:  # Double speed (2x)
			return 10.0
		2:  # Triple speed (3x)
			return 5.0
		_:
			return 15.0

func _on_auto_wave_timer_timeout():
	"""Called when the automatic wave timer expires"""
	print("Auto wave timer expired - starting next wave")

	# Stop countdown display
	stop_wave_countdown_display()

	# Clean up the timer
	var timer = td_scene.get_node("AutoWaveTimer")
	if timer:
		timer.queue_free()

	# Start the next wave
	td_scene.wave_manager.start_wave(td_scene.current_wave)

	# Update UI
	td_scene.update_ui()

func update_wave_countdown_ui(delay_seconds: float):
	"""Update UI to show countdown for next wave"""
	# This could be expanded to show a countdown timer in the UI
	print("Next wave will start in %.1f seconds" % delay_seconds)

func stop_auto_wave_timer():
	"""Stop the automatic wave timer if it exists"""
	var timer = td_scene.get_node_or_null("AutoWaveTimer")
	if timer:
		timer.queue_free()
		print("Auto wave timer stopped")

	# Stop countdown display
	stop_wave_countdown_display()

# =============================================================================
# WAVE COUNTDOWN DISPLAY SYSTEM
# =============================================================================

func start_wave_countdown_display():
	"""Start the visual countdown display"""
	if td_scene.wave_countdown_timer:
		td_scene.wave_countdown_timer.start()
		update_countdown_display()

func stop_wave_countdown_display():
	"""Stop the visual countdown display"""
	if td_scene.wave_countdown_timer:
		td_scene.wave_countdown_timer.stop()

	if td_scene.wave_countdown_label:
		td_scene.wave_countdown_label.text = ""

func _on_wave_countdown_timer_timeout():
	"""Update countdown display every second"""
	if td_scene.countdown_seconds > 0:
		td_scene.countdown_seconds -= 1.0
		update_countdown_display()
	else:
		stop_wave_countdown_display()

func update_countdown_display():
	"""Update the countdown display text"""
	if td_scene.wave_countdown_label and td_scene.countdown_seconds > 0:
		var minutes = int(td_scene.countdown_seconds) / 60
		var seconds = int(td_scene.countdown_seconds) % 60

		if minutes > 0:
			td_scene.wave_countdown_label.text = "Next wave in %d:%02d" % [minutes, seconds]
		else:
			td_scene.wave_countdown_label.text = "Next wave in %d seconds" % [int(td_scene.countdown_seconds)]
	elif td_scene.wave_countdown_label:
		td_scene.wave_countdown_label.text = ""

# =============================================================================
# WAVE COMPOSITION TIMER
# =============================================================================

func start_wave_composition_timer():
	"""Start timer to update wave composition in real-time"""
	if not td_scene.has_node("WaveCompositionTimer"):
		var timer = Timer.new()
		timer.name = "WaveCompositionTimer"
		timer.wait_time = 0.5  # Update every 0.5 seconds
		timer.timeout.connect(_on_wave_composition_timer_timeout)
		td_scene.add_child(timer)

	var timer = td_scene.get_node("WaveCompositionTimer")
	if timer:
		timer.start()

func stop_wave_composition_timer():
	"""Stop the wave composition timer"""
	if td_scene.has_node("WaveCompositionTimer"):
		var timer = td_scene.get_node("WaveCompositionTimer")
		if timer:
			timer.stop()

func _on_wave_composition_timer_timeout():
	"""Update wave composition display in real-time"""
	if td_scene.wave_composition_label and td_scene.wave_manager and td_scene.wave_manager.is_wave_in_progress():
		var composition = td_scene.wave_manager.get_wave_composition(td_scene.current_wave)
		if composition != "":
			td_scene.wave_composition_label.text = "Wave " + str(td_scene.current_wave) + ": " + composition
		else:
			td_scene.wave_composition_label.text = ""