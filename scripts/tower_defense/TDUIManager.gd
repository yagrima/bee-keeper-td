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
	
	# Show current wave or "Ready" if no wave started yet
	if td_scene.current_wave == 0:
		wave_label.text = "Wave: -"
	else:
		wave_label.text = "Wave: " + str(td_scene.current_wave)

	# Update wave composition display
	if wave_composition_label and td_scene.wave_manager:
		# Show next wave if current wave is 0 or wave is not active
		var wave_to_show = td_scene.current_wave if td_scene.current_wave > 0 else 1
		if not td_scene.wave_manager.is_wave_active and td_scene.current_wave > 0:
			wave_to_show = td_scene.current_wave + 1
		
		var composition = td_scene.wave_manager.get_wave_composition(wave_to_show)
		print("📊 update_wave_info: current_wave=%d, wave_to_show=%d, composition='%s'" % [td_scene.current_wave, wave_to_show, composition])
		
		if composition != "":
			var prefix = "Next: " if not td_scene.wave_manager.is_wave_active else ""
			wave_composition_label.text = prefix + "Wave " + str(wave_to_show) + ": " + composition
			print("✅ Wave composition label updated: '%s'" % wave_composition_label.text)
		else:
			wave_composition_label.text = "All waves completed!"
			print("⚠️ No more waves")

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
	title_label.text = "*** VICTORY! ***"
	title_label.position = Vector2(0, 30)
	title_label.size = Vector2(panel_size.x, 50)
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color.GOLD)
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
	title_label.text = "*** GAME OVER ***"
	title_label.position = Vector2(0, 30)
	title_label.size = Vector2(panel_size.x, 50)
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color.RED)
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
	# Create wave composition label in the WaveInfoPanel
	wave_composition_label = Label.new()
	wave_composition_label.name = "WaveCompositionLabel"

	# Style for panel display (left side)
	wave_composition_label.add_theme_font_size_override("font_size", 16)
	wave_composition_label.add_theme_color_override("font_color", Color(1, 0.9, 0.7, 1))  # Light beige (button text color)
	wave_composition_label.text = "Press SPACE to start first wave"
	wave_composition_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	wave_composition_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	wave_composition_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Add to WaveInfoContainer in the panel
	var wave_info_container = td_scene.get_node("UI/WaveInfoPanel/WaveInfoContainer")
	wave_info_container.add_child(wave_composition_label)
	
	print("✅ Wave composition label created in WaveInfoPanel")

func setup_wave_countdown_ui():
	"""Setup wave countdown timer display"""
	# Create wave countdown label in the WaveInfoPanel
	wave_countdown_label = Label.new()
	wave_countdown_label.name = "WaveCountdownLabel"

	# Style for panel display (right side)
	wave_countdown_label.add_theme_font_size_override("font_size", 14)
	wave_countdown_label.add_theme_color_override("font_color", Color(1, 0.9, 0.7, 1))  # Light beige (button text color)
	wave_countdown_label.text = ""
	wave_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	wave_countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	wave_countdown_label.custom_minimum_size = Vector2(200, 0)  # Fixed width for countdown

	# Add to WaveInfoContainer in the panel
	var wave_info_container = td_scene.get_node("UI/WaveInfoPanel/WaveInfoContainer")
	wave_info_container.add_child(wave_countdown_label)
	
	print("✅ Wave countdown label created in WaveInfoPanel")

	# Create countdown timer
	wave_countdown_timer = Timer.new()
	wave_countdown_timer.name = "WaveCountdownTimer"
	wave_countdown_timer.wait_time = 1.0  # Update every second
	wave_countdown_timer.timeout.connect(td_scene._on_wave_countdown_timer_timeout)
	td_scene.add_child(wave_countdown_timer)

func setup_individual_tower_buttons():
	# Create button styles
	var button_style_normal = create_button_style(Color(0.6, 0.4, 0.2, 1))
	var button_style_hover = create_button_style(Color(0.7, 0.5, 0.3, 1))
	var button_style_pressed = create_button_style(Color(0.5, 0.35, 0.2, 1))
	
	# Get the Controls VBoxContainer as parent for tower buttons
	var button_parent = td_scene.start_wave_button.get_parent()
	var button_size = Vector2(200, 50)
	var button_spacing = 60
	
	# First button position (after StartWaveButton which is 40px + 10px separation)
	var base_position = Vector2(0, 50)

	# Stinger Tower Button
	stinger_button = Button.new()
	stinger_button.name = "StingerButton"
	stinger_button.text = "Q: Stinger (20)"
	stinger_button.custom_minimum_size = button_size
	stinger_button.position = Vector2(base_position.x, base_position.y + button_spacing * 0)
	apply_button_style(stinger_button, button_style_normal, button_style_hover, button_style_pressed)
	stinger_button.pressed.connect(func(): td_scene._on_place_tower_pressed("stinger"))
	button_parent.add_child(stinger_button)

	# Propolis Bomber Button
	propolis_bomber_button = Button.new()
	propolis_bomber_button.name = "PropolisBomberButton"
	propolis_bomber_button.text = "W: Propolis (45)"
	propolis_bomber_button.custom_minimum_size = button_size
	propolis_bomber_button.position = Vector2(base_position.x, base_position.y + button_spacing * 1)
	apply_button_style(propolis_bomber_button, button_style_normal, button_style_hover, button_style_pressed)
	propolis_bomber_button.pressed.connect(func(): td_scene._on_place_tower_pressed("propolis_bomber"))
	button_parent.add_child(propolis_bomber_button)

	# Nectar Sprayer Button
	nectar_sprayer_button = Button.new()
	nectar_sprayer_button.name = "NectarSprayerButton"
	nectar_sprayer_button.text = "E: Nectar (30)"
	nectar_sprayer_button.custom_minimum_size = button_size
	nectar_sprayer_button.position = Vector2(base_position.x, base_position.y + button_spacing * 2)
	apply_button_style(nectar_sprayer_button, button_style_normal, button_style_hover, button_style_pressed)
	nectar_sprayer_button.pressed.connect(func(): td_scene._on_place_tower_pressed("nectar_sprayer"))
	button_parent.add_child(nectar_sprayer_button)

	# Lightning Flower Button
	lightning_flower_button = Button.new()
	lightning_flower_button.name = "LightningFlowerButton"
	lightning_flower_button.text = "R: Lightning (35)"
	lightning_flower_button.custom_minimum_size = button_size
	lightning_flower_button.position = Vector2(base_position.x, base_position.y + button_spacing * 3)
	apply_button_style(lightning_flower_button, button_style_normal, button_style_hover, button_style_pressed)
	lightning_flower_button.pressed.connect(func(): td_scene._on_place_tower_pressed("lightning_flower"))
	button_parent.add_child(lightning_flower_button)

	# Update selection to show current tower
	update_button_selection()

func create_button_style(bg_color: Color) -> StyleBoxFlat:
	"""Create a StyleBoxFlat for buttons"""
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.25, 0.15, 1)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	return style

func apply_button_style(button: Button, style_normal: StyleBoxFlat, style_hover: StyleBoxFlat, style_pressed: StyleBoxFlat):
	"""Apply styles to a button"""
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)
	button.add_theme_color_override("font_color", Color(1, 0.9, 0.7, 1))
	button.add_theme_font_size_override("font_size", 16)

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
	td_scene.add_debug_message("→ setup_speed_button() START")
	
	# Create button styles
	var button_style_normal = create_button_style(Color(0.6, 0.4, 0.2, 1))
	var button_style_hover = create_button_style(Color(0.7, 0.5, 0.3, 1))
	var button_style_pressed = create_button_style(Color(0.5, 0.35, 0.2, 1))
	
	# Create speed button below the tower buttons
	speed_button = Button.new()
	speed_button.name = "SpeedButton"
	speed_button.custom_minimum_size = Vector2(200, 50)
	
	td_scene.add_debug_message("→ Button created")

	# Position it below the lightning flower button
	var lightning_pos = lightning_flower_button.position
	speed_button.position = Vector2(lightning_pos.x, lightning_pos.y + 60)

	# Apply styles
	apply_button_style(speed_button, button_style_normal, button_style_hover, button_style_pressed)

	# Connect signal
	speed_button.pressed.connect(td_scene._on_speed_button_pressed)
	td_scene.add_debug_message("→ Signal connected")

	# Add to same parent as tower buttons
	lightning_flower_button.get_parent().add_child(speed_button)
	td_scene.add_debug_message("→ Added to scene")

	# Initialize button text
	update_speed_button_text()
	td_scene.add_debug_message("✅ setup_speed_button() DONE")

func update_speed_button_text():
	td_scene.add_debug_message("→ update_speed_button_text() called")
	
	if not speed_button:
		td_scene.add_debug_message("ERROR: speed_button NULL!")
		return
	
	td_scene.add_debug_message("→ speed_mode: %d" % td_scene.speed_mode)
	
	var speed_text = ""
	match td_scene.speed_mode:
		0:
			speed_text = HotkeyManager.get_action_display_text("speed_toggle") + " - 1x"
		1:
			speed_text = HotkeyManager.get_action_display_text("speed_toggle") + " - 2x"
		2:
			speed_text = HotkeyManager.get_action_display_text("speed_toggle") + " - 3x"
	
	td_scene.add_debug_message("→ new text: %s" % speed_text)
	speed_button.text = speed_text
	td_scene.add_debug_message("✅ Button updated!")

func update_button_texts():
	"""Update button texts with current hotkey assignments"""
	if start_wave_button:
		start_wave_button.text = HotkeyManager.get_action_display_text("start_wave")
	if place_tower_button:
		place_tower_button.text = HotkeyManager.get_action_display_text("place_tower")