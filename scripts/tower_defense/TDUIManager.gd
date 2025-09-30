class_name TDUIManager
extends Node

# Reference to the main TowerDefense scene
var td_scene: Node2D

# UI element references
var honey_label: Label
var health_label: Label
var wave_label: Label
var wave_composition_label: Label
var wave_countdown_label: Label
var start_wave_button: Button
var place_tower_button: Button
var speed_button: Button

# Individual tower buttons
var stinger_button: Button
var propolis_bomber_button: Button
var nectar_sprayer_button: Button
var lightning_flower_button: Button

# Wave countdown timer
var wave_countdown_timer: Timer

func _init(p_td_scene: Node2D):
	td_scene = p_td_scene

func update_ui():
	honey_label.text = "Honey: " + str(GameManager.get_resource("honey"))
	health_label.text = "Health: " + str(td_scene.player_health)
	wave_label.text = "Wave: " + str(td_scene.current_wave)

	# Update wave composition display
	if wave_composition_label and td_scene.wave_manager:
		var composition = td_scene.wave_manager.get_wave_composition(td_scene.current_wave)
		var scaling_info = td_scene.wave_manager.get_wave_scaling_info()
		if composition != "":
			wave_composition_label.text = "Wave " + str(td_scene.current_wave) + ": " + composition + " (" + scaling_info + ")"
		else:
			wave_composition_label.text = ""

func show_insufficient_honey_dialog(required_honey: int, current_honey: int):
	"""Show dialog when player doesn't have enough honey"""
	var dialog = AcceptDialog.new()
	dialog.title = "Insufficient Honey"
	dialog.dialog_text = "You need " + str(required_honey) + " honey to build this tower.\nYou currently have " + str(current_honey) + " honey."
	dialog.size = Vector2(300, 150)

	# Add to scene
	var ui_canvas = td_scene.get_node("UI")
	ui_canvas.add_child(dialog)

	# Center the dialog
	var window_size = Vector2(td_scene.get_viewport().get_visible_rect().size)
	dialog.position = (window_size - Vector2(dialog.size)) / 2

	# Auto-close after 3 seconds
	var timer = td_scene.get_tree().create_timer(3.0)
	timer.timeout.connect(dialog.queue_free)

func show_victory_screen():
	# Create victory overlay
	var victory_overlay = ColorRect.new()
	victory_overlay.name = "VictoryOverlay"
	victory_overlay.color = Color(0, 0, 0, 0.7)  # Semi-transparent black
	victory_overlay.size = Vector2(td_scene.get_viewport().get_visible_rect().size)
	victory_overlay.position = Vector2.ZERO
	victory_overlay.z_index = 100  # Ensure it's on top

	# Create victory panel
	var victory_panel = Panel.new()
	victory_panel.name = "VictoryPanel"
	var panel_size = Vector2(400, 300)
	var window_size = Vector2(td_scene.get_viewport().get_visible_rect().size)
	victory_panel.size = panel_size
	victory_panel.position = (window_size - panel_size) / 2  # Center the panel

	# Style the panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.2, 0.4, 0.2)  # Dark green
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color.GOLD
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	victory_panel.add_theme_stylebox_override("panel", panel_style)

	# Victory title
	var title_label = Label.new()
	title_label.text = "🏆 VICTORY! 🏆"
	title_label.position = Vector2(0, 30)
	title_label.size = Vector2(panel_size.x, 50)
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	victory_panel.add_child(title_label)

	# Victory message
	var message_label = Label.new()
	message_label.text = "All waves successfully defended!\nThe hive is safe!"
	message_label.position = Vector2(0, 80)
	message_label.size = Vector2(panel_size.x, 60)
	message_label.add_theme_font_size_override("font_size", 18)
	message_label.add_theme_color_override("font_color", Color.WHITE)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	victory_panel.add_child(message_label)

	# Statistics
	var stats_label = Label.new()
	var final_honey = GameManager.get_resource("honey")
	stats_label.text = "Verbleibendes Leben:\nHealth: " + str(td_scene.player_health) + "/20\nWaves Completed: 5/5"
	stats_label.position = Vector2(0, 140)
	stats_label.size = Vector2(panel_size.x, 60)
	stats_label.add_theme_font_size_override("font_size", 16)
	stats_label.add_theme_color_override("font_color", Color.WHITE)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	victory_panel.add_child(stats_label)

	# Return to menu button
	var menu_button = Button.new()
	menu_button.text = "Return to Main Menu"
	menu_button.size = Vector2(200, 40)
	menu_button.position = Vector2(panel_size.x / 2 - 100, 250)

	# Connect the button signal with error handling
	if not menu_button.pressed.is_connected(_on_victory_menu_button_pressed):
		menu_button.pressed.connect(_on_victory_menu_button_pressed)
		print("Victory menu button connected successfully")
	else:
		print("Victory menu button already connected")

	# Connect alternative handler as backup
	if not menu_button.pressed.is_connected(_on_victory_button_clicked):
		menu_button.pressed.connect(_on_victory_button_clicked)
		print("Victory button alternative handler connected")

	# Alternative: Use call_deferred to ensure the connection works
	call_deferred("_connect_victory_button", menu_button)

	victory_panel.add_child(menu_button)

	# Add to scene
	victory_overlay.add_child(victory_panel)
	var ui_canvas = td_scene.get_node("UI")
	ui_canvas.add_child(victory_overlay)

	# Disable game controls
	start_wave_button.disabled = true
	place_tower_button.disabled = true

	# Don't pause the game - this prevents UI from working
	# get_tree().paused = true

func _on_victory_menu_button_pressed():
	print("Victory menu button pressed - returning to main menu")

	# Clean up victory screen
	cleanup_victory_screen()

	# Return to main menu
	SceneManager.goto_main_menu()

func _on_victory_button_clicked():
	# Alternative button handler
	print("Victory button clicked - alternative handler")
	_on_victory_menu_button_pressed()

func cleanup_victory_screen():
	# Remove victory overlay if it exists
	var victory_overlay = td_scene.get_node("UI").get_node_or_null("VictoryOverlay")
	if victory_overlay:
		victory_overlay.queue_free()
		print("Victory overlay cleaned up")

func _connect_victory_button(button: Button):
	# Ensure the button is properly connected
	if button and not button.pressed.is_connected(_on_victory_menu_button_pressed):
		button.pressed.connect(_on_victory_menu_button_pressed)
		print("Victory button connected via deferred call")

func show_game_over_screen():
	# Create game over overlay
	var game_over_overlay = ColorRect.new()
	game_over_overlay.name = "GameOverOverlay"
	game_over_overlay.color = Color(0, 0, 0, 0.8)  # Semi-transparent black
	game_over_overlay.size = Vector2(td_scene.get_viewport().get_visible_rect().size)
	game_over_overlay.position = Vector2.ZERO
	game_over_overlay.z_index = 100  # Ensure it's on top

	# Create game over panel
	var game_over_panel = Panel.new()
	game_over_panel.name = "GameOverPanel"
	var panel_size = Vector2(400, 300)
	var window_size = Vector2(td_scene.get_viewport().get_visible_rect().size)
	game_over_panel.size = panel_size
	game_over_panel.position = (window_size - panel_size) / 2  # Center the panel

	# Style the panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.4, 0.2, 0.2)  # Dark red
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = Color.RED
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	game_over_panel.add_theme_stylebox_override("panel", panel_style)

	# Game over title
	var title_label = Label.new()
	title_label.text = "💀 GAME OVER 💀"
	title_label.position = Vector2(0, 30)
	title_label.size = Vector2(panel_size.x, 50)
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_over_panel.add_child(title_label)

	# Game over message
	var message_label = Label.new()
	message_label.text = "The hive has been overrun!\nYour defenses have failed!"
	message_label.position = Vector2(0, 80)
	message_label.size = Vector2(panel_size.x, 60)
	message_label.add_theme_font_size_override("font_size", 18)
	message_label.add_theme_color_override("font_color", Color.WHITE)
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_over_panel.add_child(message_label)

	# Statistics
	var stats_label = Label.new()
	var final_honey = GameManager.get_resource("honey")
	stats_label.text = "Final Score:\nHoney Collected: " + str(final_honey) + "\nWaves Survived: " + str(td_scene.current_wave - 1) + "/5"
	stats_label.position = Vector2(0, 140)
	stats_label.size = Vector2(panel_size.x, 60)
	stats_label.add_theme_font_size_override("font_size", 16)
	stats_label.add_theme_color_override("font_color", Color.WHITE)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	game_over_panel.add_child(stats_label)

	# Return to menu button
	var menu_button = Button.new()
	menu_button.text = "Return to Main Menu"
	menu_button.size = Vector2(200, 40)
	menu_button.position = Vector2(panel_size.x / 2 - 100, 250)
	menu_button.pressed.connect(_on_game_over_menu_button_pressed)
	game_over_panel.add_child(menu_button)

	# Add to scene
	game_over_overlay.add_child(game_over_panel)
	var ui_canvas = td_scene.get_node("UI")
	ui_canvas.add_child(game_over_overlay)

	# Disable game controls
	start_wave_button.disabled = true
	place_tower_button.disabled = true

	# Don't pause the game - this prevents UI from working
	# get_tree().paused = true

func _on_game_over_menu_button_pressed():
	print("Game over menu button pressed - returning to main menu")

	# Clean up game over screen
	cleanup_game_over_screen()

	# Return to main menu
	SceneManager.goto_main_menu()

func cleanup_game_over_screen():
	# Remove game over overlay if it exists
	var game_over_overlay = td_scene.get_node("UI").get_node_or_null("GameOverOverlay")
	if game_over_overlay:
		game_over_overlay.queue_free()
		print("Game over overlay cleaned up")

func setup_wave_composition_ui():
	# Create wave composition label and position it to avoid overlap
	wave_composition_label = Label.new()
	wave_composition_label.name = "WaveCompositionLabel"

	# Position it below the resource display area with proper spacing
	wave_composition_label.position = Vector2(20, 70)  # Positioned below resource display
	wave_composition_label.add_theme_font_size_override("font_size", 13)  # Smaller font for better fit
	wave_composition_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))  # Slightly lighter
	wave_composition_label.text = ""
	wave_composition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	wave_composition_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	# Add to UI layer
	var ui_canvas = td_scene.get_node("UI")
	ui_canvas.add_child(wave_composition_label)

func setup_wave_countdown_ui():
	"""Setup wave countdown timer display"""
	# Create wave countdown label
	wave_countdown_label = Label.new()
	wave_countdown_label.name = "WaveCountdownLabel"

	# Position it below the wave composition label
	wave_countdown_label.position = Vector2(20, 90)  # Below wave composition
	wave_countdown_label.add_theme_font_size_override("font_size", 12)
	wave_countdown_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))  # Same color as other labels
	wave_countdown_label.text = ""
	wave_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	wave_countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	# Add to UI layer
	var ui_canvas = td_scene.get_node("UI")
	ui_canvas.add_child(wave_countdown_label)

	# Create countdown timer
	wave_countdown_timer = Timer.new()
	wave_countdown_timer.name = "WaveCountdownTimer"
	wave_countdown_timer.wait_time = 1.0  # Update every second
	wave_countdown_timer.timeout.connect(td_scene._on_wave_countdown_timer_timeout)
	td_scene.add_child(wave_countdown_timer)

func setup_individual_tower_buttons():
	# Create four individual tower buttons
	var button_parent = place_tower_button.get_parent()
	var base_position = place_tower_button.position
	var button_size = Vector2(130, 40)
	var button_spacing = 140

	# Stinger Tower Button
	stinger_button = Button.new()
	stinger_button.name = "StingerButton"
	stinger_button.text = "Q: Stinger (20)"
	stinger_button.size = button_size
	stinger_button.position = Vector2(base_position.x + button_spacing * 0, base_position.y)
	stinger_button.pressed.connect(func(): td_scene._on_place_tower_pressed("stinger"))
	button_parent.add_child(stinger_button)

	# Propolis Bomber Button
	propolis_bomber_button = Button.new()
	propolis_bomber_button.name = "PropolisBomberButton"
	propolis_bomber_button.text = "W: Propolis (45)"
	propolis_bomber_button.size = button_size
	propolis_bomber_button.position = Vector2(base_position.x + button_spacing * 1, base_position.y)
	propolis_bomber_button.pressed.connect(func(): td_scene._on_place_tower_pressed("propolis_bomber"))
	button_parent.add_child(propolis_bomber_button)

	# Nectar Sprayer Button
	nectar_sprayer_button = Button.new()
	nectar_sprayer_button.name = "NectarSprayerButton"
	nectar_sprayer_button.text = "E: Nectar (30)"
	nectar_sprayer_button.size = button_size
	nectar_sprayer_button.position = Vector2(base_position.x + button_spacing * 2, base_position.y)
	nectar_sprayer_button.pressed.connect(func(): td_scene._on_place_tower_pressed("nectar_sprayer"))
	button_parent.add_child(nectar_sprayer_button)

	# Lightning Flower Button
	lightning_flower_button = Button.new()
	lightning_flower_button.name = "LightningFlowerButton"
	lightning_flower_button.text = "R: Lightning (35)"
	lightning_flower_button.size = button_size
	lightning_flower_button.position = Vector2(base_position.x + button_spacing * 3, base_position.y)
	lightning_flower_button.pressed.connect(func(): td_scene._on_place_tower_pressed("lightning_flower"))
	button_parent.add_child(lightning_flower_button)

	# Hide the old place tower button
	if place_tower_button:
		place_tower_button.visible = false

	# Update selection to show current tower
	update_button_selection()

func update_button_selection():
	"""Update button visual state to show current selection"""
	# Reset all buttons
	if stinger_button:
		stinger_button.button_pressed = false
	if propolis_bomber_button:
		propolis_bomber_button.button_pressed = false
	if nectar_sprayer_button:
		nectar_sprayer_button.button_pressed = false
	if lightning_flower_button:
		lightning_flower_button.button_pressed = false

	# Highlight current selection
	match td_scene.current_tower_type:
		"stinger":
			if stinger_button:
				stinger_button.button_pressed = true
		"propolis_bomber":
			if propolis_bomber_button:
				propolis_bomber_button.button_pressed = true
		"nectar_sprayer":
			if nectar_sprayer_button:
				nectar_sprayer_button.button_pressed = true
		"lightning_flower":
			if lightning_flower_button:
				lightning_flower_button.button_pressed = true

func setup_speed_button():
	# Create speed button next to the tower buttons
	speed_button = Button.new()
	speed_button.name = "SpeedButton"
	speed_button.size = Vector2(150, 40)

	# Position it next to the lightning flower button
	var lightning_pos = lightning_flower_button.position
	speed_button.position = Vector2(lightning_pos.x + 150, lightning_pos.y)

	# Connect signal
	if speed_button:
		speed_button.pressed.connect(td_scene._on_speed_button_pressed)

	# Add to same parent as tower buttons
	lightning_flower_button.get_parent().add_child(speed_button)

	# Initialize button text
	update_speed_button_text()

func update_speed_button_text():
	if speed_button:
		match td_scene.speed_mode:
			0:
				speed_button.text = HotkeyManager.get_action_display_text("speed_toggle") + " (1x)"
			1:
				speed_button.text = HotkeyManager.get_action_display_text("speed_toggle") + " (2x)"
			2:
				speed_button.text = HotkeyManager.get_action_display_text("speed_toggle") + " (3x)"

func update_button_texts():
	"""Update button texts with current hotkey assignments"""
	if start_wave_button:
		start_wave_button.text = HotkeyManager.get_action_display_text("start_wave")
	if place_tower_button:
		place_tower_button.text = HotkeyManager.get_action_display_text("place_tower")