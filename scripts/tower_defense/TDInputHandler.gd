class_name TDInputHandler
extends RefCounted

# =============================================================================
# TOWER DEFENSE INPUT HANDLER
# =============================================================================
# Handles all input processing for the Tower Defense scene
# - Keyboard input (hotkeys)
# - Mouse input (tower selection, placement)
# - Debug message logging
# =============================================================================

var td_scene: Node2D
var is_development_build: bool = false
var debug_messages: Array[String] = []
const MAX_DEBUG_MESSAGES = 25

func _init(scene: Node2D):
	td_scene = scene

func handle_input(event: InputEvent) -> bool:
	"""
	Handle input events for tower defense
	Returns true if event was handled and should not propagate
	"""
	# Debug: Log keyboard events in-game
	if event is InputEventKey and event.pressed and not event.is_echo():
		var key_name = OS.get_keycode_string(event.keycode)
		add_debug_message("KEY: %s (code: %d)" % [key_name, event.keycode])
		
		if event.keycode == KEY_F:
			add_debug_message("  -> F DETECTED!")
			add_debug_message("  -> HotkeyMgr: %d" % HotkeyManager.get_hotkey("speed_toggle"))
			var is_speed = HotkeyManager.is_hotkey_pressed(event, "speed_toggle")
			add_debug_message("  -> is_hotkey: %s" % is_speed)
			if is_speed:
				add_debug_message("  -> CALLING _on_speed_button_pressed()")
	
	# Handle mouse clicks for tower selection
	if event is InputEventMouseButton and event.pressed:
		return handle_mouse_click(event)
	
	# Handle keyboard events
	if event is InputEventKey and event.pressed and not event.is_echo():
		return handle_keyboard_input(event)
	
	return false

func handle_mouse_click(event: InputEventMouseButton) -> bool:
	"""Handle mouse click events"""
	print("\n" + "=".repeat(80))
	print("🖱️ MOUSE INPUT EVENT")
	print("Button: %d, Position: %s" % [event.button_index, event.position])
	print("picked_up_tower: %s" % ("YES - " + td_scene.metaprogression.picked_up_tower.tower_name if td_scene.metaprogression.picked_up_tower else "NO"))
	print("is_in_tower_placement: %s" % td_scene.is_in_tower_placement)
	print("=".repeat(80))

	if event.button_index == MOUSE_BUTTON_LEFT:
		# Check for metaprogression tower pickup first
		print("→ Calling handle_metaprogression_tower_pickup...")
		var handled = td_scene.metaprogression.handle_metaprogression_tower_pickup(event.position)
		print("→ handle_metaprogression_tower_pickup returned: %s" % handled)
		if handled:
			print("✅ Event handled by metaprogression system\n")
			return true
		
		# Then handle regular tower selection
		print("→ Calling handle_tower_click...")
		td_scene.handle_tower_click(event.position)
		return true
	
	elif event.button_index == MOUSE_BUTTON_RIGHT:
		# Right click - clear selection
		td_scene.clear_tower_selection()
		return true
	
	return false

func handle_keyboard_input(event: InputEventKey) -> bool:
	"""Handle keyboard input events"""
	# Use dynamic hotkey system
	if HotkeyManager.is_hotkey_pressed(event, "place_stinger"):
		td_scene.handle_tower_hotkey("stinger", "Stinger Tower")
		return true
	elif HotkeyManager.is_hotkey_pressed(event, "place_propolis_bomber"):
		td_scene.handle_tower_hotkey("propolis_bomber", "Propolis Bomber Tower")
		return true
	elif HotkeyManager.is_hotkey_pressed(event, "place_nectar_sprayer"):
		td_scene.handle_tower_hotkey("nectar_sprayer", "Nectar Sprayer Tower")
		return true
	elif HotkeyManager.is_hotkey_pressed(event, "place_lightning_flower"):
		td_scene.handle_tower_hotkey("lightning_flower", "Lightning Flower Tower")
		return true
	elif HotkeyManager.is_hotkey_pressed(event, "place_tower"):
		# Toggle tower placement mode with current tower
		if td_scene.is_in_tower_placement:
			td_scene.tower_placer.cancel_placement()
		else:
			td_scene.tower_placer.start_tower_placement(td_scene.current_tower_type)
		return true
	elif HotkeyManager.is_hotkey_pressed(event, "start_wave"):
		# Start wave
		td_scene._on_start_wave_pressed()
		return true
	elif HotkeyManager.is_hotkey_pressed(event, "speed_toggle"):
		# Toggle speed
		td_scene._on_speed_button_pressed()
		return true
	
	return false

func add_debug_message(msg: String):
	"""Add a message to the debug overlay (only in development builds)"""
	if not is_development_build or not td_scene.debug_label:
		return
	
	debug_messages.append(msg)
	if debug_messages.size() > MAX_DEBUG_MESSAGES:
		debug_messages.pop_front()
	
	if td_scene.debug_label:
		td_scene.debug_label.text = "\n".join(debug_messages)
