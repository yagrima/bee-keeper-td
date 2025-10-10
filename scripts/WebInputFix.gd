class_name WebInputFix
extends RefCounted

# =============================================================================
# WEB INPUT FIX
# =============================================================================
# Direct input handler bypassing complex delegation for web builds
# Workaround for Godot 4.5 Web export input issues
# =============================================================================

var td_scene: Node2D
var is_web_build: bool = false

# =============================================================================
# DEBUG TOGGLE
# =============================================================================
const DEBUG_ENABLED: bool = true  # Set to false for production

func _init(scene: Node2D):
	td_scene = scene
	is_web_build = OS.has_feature("web")
	
	if DEBUG_ENABLED:
		print("🔧 WebInputFix initialized (Web build: %s)" % is_web_build)

# =============================================================================
# DIRECT INPUT BYPASS
# =============================================================================

func bypass_input_system(event: InputEvent) -> bool:
	"""
	Direct input handler for web builds that bypasses complex delegation
	Returns true if event was handled
	"""
	if not is_web_build:
		return false
	
	# Direct mouse click handling
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if DEBUG_ENABLED:
				print("🖱️ WEB: Direct mouse click at position: %s" % event.position)
			
			# Directly call tower placement without delegation chain
			if td_scene.current_tower_type and td_scene.is_in_tower_placement:
				# Let normal system handle placement
				return false
			elif td_scene.current_tower_type:
				td_scene.tower_placer.start_tower_placement(td_scene.current_tower_type)
				return true
			return false
			
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if DEBUG_ENABLED:
				print("🖱️ WEB: Direct right-click - Clear selection")
			td_scene.clear_tower_selection()
			return true
	
	# Direct keyboard handling with fallback
	if event is InputEventKey and event.pressed:
		var keycode = event.keycode
		
		# Manual hotkey detection
		if keycode == KEY_Q:
			if DEBUG_ENABLED:
				print("⌨️  WEB: Direct Q key - Stinger Tower")
			td_scene.handle_tower_hotkey("stinger", "Stinger Tower")
			return true
			
		elif keycode == KEY_W:
			if DEBUG_ENABLED:
				print("⌨️  WEB: Direct W key - Propolis Bomber")
			td_scene.handle_tower_hotkey("propolis_bomber", "Propolis Bomber Tower")
			return true
			
		elif keycode == KEY_E:
			if DEBUG_ENABLED:
				print("⌨️  WEB: Direct E key - Nectar Sprayer")
			td_scene.handle_tower_hotkey("nectar_sprayer", "Nectar Sprayer Tower")
			return true
			
		elif keycode == KEY_R:
			if DEBUG_ENABLED:
				print("⌨️  WEB: Direct R key - Lightning Flower")
			td_scene.handle_tower_hotkey("lightning_flower", "Lightning Flower Tower")
			return true
			
		elif keycode == KEY_SPACE:
			if DEBUG_ENABLED:
				print("⌨️  WEB: Direct SPACE key - Start Wave")
			td_scene._on_start_wave_pressed()
			return true
			
		elif keycode == KEY_F:
			if DEBUG_ENABLED:
				print("⌨️  WEB: Direct F key - Speed Toggle")
			td_scene._on_speed_button_pressed()
			return true
			
		elif keycode == KEY_ESCAPE:
			if DEBUG_ENABLED:
				print("⌨️  WEB: Direct ESC key - Clear Selection")
			td_scene.clear_tower_selection()
			return true
	
	return false

# =============================================================================
# DIRECT BUTTON SIGNAL SETUP
# =============================================================================

func setup_web_button_signals():
	"""
	Direct button signal connections for web builds
	Bypasses complex UI signal chain
	"""
	if not is_web_build:
		return
	
	if DEBUG_ENABLED:
		print("🔧 WEB: Setting up direct button signals")
	
	# Direct start wave button
	var start_btn = td_scene.find_child("StartWaveButton", true, false)
	if start_btn and start_btn is Button:
		# Disconnect existing to avoid duplication
		if start_btn.pressed.is_connected(_on_start_wave_pressed_direct):
			start_btn.pressed.disconnect(_on_start_wave_pressed_direct)
		start_btn.pressed.connect(_on_start_wave_pressed_direct)
		if DEBUG_ENABLED:
			print("✅ WEB: StartWaveButton connected directly")
	
	# Direct speed button
	var speed_btn = td_scene.find_child("SpeedButton", true, false)
	if speed_btn and speed_btn is Button:
		if speed_btn.pressed.is_connected(_on_speed_button_pressed_direct):
			speed_btn.pressed.disconnect(_on_speed_button_pressed_direct)
		speed_btn.pressed.connect(_on_speed_button_pressed_direct)
		if DEBUG_ENABLED:
			print("✅ WEB: SpeedButton connected directly")

func _on_start_wave_pressed_direct():
	"""Direct handler for start wave button in web builds"""
	if DEBUG_ENABLED:
		print("🖱️ WEB: Start Wave button clicked directly")
	td_scene._on_start_wave_pressed()

func _on_speed_button_pressed_direct():
	"""Direct handler for speed button in web builds"""
	if DEBUG_ENABLED:
		print("🖱️ WEB: Speed button clicked directly")
	td_scene._on_speed_button_pressed()
