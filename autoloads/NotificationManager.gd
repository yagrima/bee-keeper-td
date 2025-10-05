extends Node

# Notification Manager - UI Feedback System
# Displays loading states, success messages, and errors

signal notification_shown(type: String, message: String)
signal notification_hidden()

enum NotificationType {
	INFO,
	SUCCESS,
	WARNING,
	ERROR,
	LOADING
}

# UI References
var notification_panel: Panel
var notification_label: Label
var loading_spinner: TextureProgressBar
var auto_hide_timer: Timer

# State
var is_showing: bool = false
var current_type: NotificationType = NotificationType.INFO

func _ready():
	# Will be initialized when first notification is shown
	print("NotificationManager initialized")

	# Connect to SaveManager and SupabaseClient signals
	call_deferred("_connect_to_signals")

func _connect_to_signals():
	"""Connect to all relevant signals"""
	_connect_to_save_manager()
	_connect_to_supabase_client()

func show_loading(message: String = "Loading..."):
	"""Show loading state with spinner"""
	_show_notification(message, NotificationType.LOADING, 0)  # 0 = don't auto-hide

func show_success(message: String, duration: float = 3.0):
	"""Show success message (green, auto-hide)"""
	_show_notification(message, NotificationType.SUCCESS, duration)

func show_error(message: String, duration: float = 5.0):
	"""Show error message (red, longer duration)"""
	_show_notification(message, NotificationType.ERROR, duration)

func show_warning(message: String, duration: float = 4.0):
	"""Show warning message (yellow)"""
	_show_notification(message, NotificationType.WARNING, duration)

func show_info(message: String, duration: float = 3.0):
	"""Show info message (blue)"""
	_show_notification(message, NotificationType.INFO, duration)

func hide_notification():
	"""Manually hide current notification"""
	if notification_panel and is_instance_valid(notification_panel):
		notification_panel.hide()
		is_showing = false
		notification_hidden.emit()

func _show_notification(message: String, type: NotificationType, duration: float):
	"""Internal: Show notification with type and auto-hide duration"""

	# Create UI if not exists
	if not notification_panel or not is_instance_valid(notification_panel):
		_create_notification_ui()

	current_type = type
	is_showing = true

	# Update message
	notification_label.text = message

	# Update colors based on type
	match type:
		NotificationType.INFO:
			notification_panel.modulate = Color(0.2, 0.4, 0.8, 0.95)  # Blue
			if loading_spinner:
				loading_spinner.hide()
		NotificationType.SUCCESS:
			notification_panel.modulate = Color(0.2, 0.8, 0.2, 0.95)  # Green
			if loading_spinner:
				loading_spinner.hide()
		NotificationType.WARNING:
			notification_panel.modulate = Color(0.9, 0.7, 0.2, 0.95)  # Yellow
			if loading_spinner:
				loading_spinner.hide()
		NotificationType.ERROR:
			notification_panel.modulate = Color(0.9, 0.2, 0.2, 0.95)  # Red
			if loading_spinner:
				loading_spinner.hide()
		NotificationType.LOADING:
			notification_panel.modulate = Color(0.3, 0.3, 0.3, 0.95)  # Gray
			if loading_spinner:
				loading_spinner.show()

	# Show panel
	notification_panel.show()

	# Setup auto-hide timer
	if duration > 0:
		if auto_hide_timer:
			auto_hide_timer.stop()
			auto_hide_timer.wait_time = duration
			auto_hide_timer.start()
	else:
		# Cancel auto-hide for loading states
		if auto_hide_timer:
			auto_hide_timer.stop()

	notification_shown.emit(NotificationType.keys()[type], message)
	print("📢 Notification [%s]: %s" % [NotificationType.keys()[type], message])

func _create_notification_ui():
	"""Create notification UI panel"""

	# Create panel
	notification_panel = Panel.new()
	notification_panel.name = "NotificationPanel"
	notification_panel.custom_minimum_size = Vector2(400, 60)
	notification_panel.z_index = 1000  # Always on top

	# Style the panel
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.2, 0.95)
	style.border_width_left = 4
	style.border_width_right = 4
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.border_color = Color(1, 1, 1, 0.3)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	notification_panel.add_theme_stylebox_override("panel", style)

	# Create label
	notification_label = Label.new()
	notification_label.name = "NotificationLabel"
	notification_label.text = "Notification"
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notification_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Add label to panel
	notification_panel.add_child(notification_label)

	# Position label to fill panel
	notification_label.anchor_left = 0.0
	notification_label.anchor_right = 1.0
	notification_label.anchor_top = 0.0
	notification_label.anchor_bottom = 1.0
	notification_label.offset_left = 10
	notification_label.offset_right = -10
	notification_label.offset_top = 10
	notification_label.offset_bottom = -10

	# Create auto-hide timer
	auto_hide_timer = Timer.new()
	auto_hide_timer.name = "AutoHideTimer"
	auto_hide_timer.one_shot = true
	auto_hide_timer.timeout.connect(_on_auto_hide_timeout)
	notification_panel.add_child(auto_hide_timer)

	# Add to scene tree (as child of root)
	get_tree().root.add_child(notification_panel)

	# Position at top-center of screen
	_position_notification()

	# Initially hidden
	notification_panel.hide()

	print("Notification UI created")

func _position_notification():
	"""Position notification at top-center of screen"""
	if not notification_panel:
		return

	var viewport_size = get_viewport().get_visible_rect().size
	var panel_size = notification_panel.custom_minimum_size

	notification_panel.position = Vector2(
		(viewport_size.x - panel_size.x) / 2,  # Center horizontally
		20  # 20px from top
	)

func _on_auto_hide_timeout():
	"""Auto-hide notification after timer expires"""
	hide_notification()

# Connect to SaveManager signals
func _connect_to_save_manager():
	"""Connect to SaveManager signals for automatic feedback"""
	if SaveManager:
		SaveManager.cloud_sync_started.connect(_on_cloud_sync_started)
		SaveManager.cloud_sync_completed.connect(_on_cloud_sync_completed)
		SaveManager.save_completed.connect(_on_save_completed)
		SaveManager.load_completed.connect(_on_load_completed)
		print("NotificationManager connected to SaveManager signals")

func _on_cloud_sync_started():
	"""Handle cloud sync start"""
	show_loading("☁️ Syncing to cloud...")

func _on_cloud_sync_completed(success: bool):
	"""Handle cloud sync completion"""
	if success:
		show_success("✅ Cloud sync complete")
	else:
		show_error("❌ Cloud sync failed")

func _on_save_completed(success: bool, message: String):
	"""Handle save completion"""
	if success:
		show_success("💾 " + message)
	else:
		show_error("❌ " + message)

func _on_load_completed(success: bool, message: String):
	"""Handle load completion"""
	if success:
		show_success("📂 " + message)
	else:
		show_error("❌ " + message)

# Connect to SupabaseClient signals
func _connect_to_supabase_client():
	"""Connect to SupabaseClient signals for auth feedback"""
	if SupabaseClient:
		# Note: SupabaseClient doesn't expose auth signals yet
		# Will add if needed
		print("NotificationManager: SupabaseClient connection ready")

