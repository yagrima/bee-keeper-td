extends Control

@onready var play_button = $UI/MenuContainer/PlayButton
@onready var td_button = $UI/MenuContainer/TDButton
@onready var settlement_button = $UI/MenuContainer/SettlementButton
@onready var load_button = $UI/MenuContainer/LoadButton
@onready var quit_button = $UI/MenuContainer/QuitButton

# =============================================================================
# TESTING REMINDER SYSTEM
# =============================================================================
# This system reminds developers to update tests when new features are added
# TODO: Update this list whenever new features are implemented

# Current test coverage (update when adding features):
var test_coverage = {
	"speed_system": {
		"description": "3-speed system (1x, 2x, 3x)",
		"tests": ["projectile_speed_ratios", "speed_mode_transitions"],
		"last_updated": "2024-12-19"
	},
	"tower_system": {
		"description": "Basic Shooter, Piercing Shooter towers",
		"tests": ["tower_placement", "tower_attacks"],
		"last_updated": "2024-12-19"
	},
	"enemy_system": {
		"description": "Standard enemies with health bars",
		"tests": ["enemy_spawning", "enemy_movement"],
		"last_updated": "2024-12-19"
	},
	"projectile_system": {
		"description": "Homing projectiles with collision detection",
		"tests": ["projectile_homing", "collision_detection"],
		"last_updated": "2024-12-19"
	},
	"ui_system": {
		"description": "Buttons, hotkeys, range indicators",
		"tests": ["button_functionality", "hotkey_system", "range_indicators"],
		"last_updated": "2024-12-19"
	},
	"save_system": {
		"description": "JSON-based save/load system",
		"tests": ["save_data_structure", "load_functionality"],
		"last_updated": "2024-12-19"
	}
}

# Features that need test updates (add new features here):
var pending_test_updates = [
	# Add new features here when implementing them
	# Example: "new_tower_type", "new_enemy_type", "new_ui_feature"
]

# Test reminder configuration
var test_reminder_enabled = true
var last_reminder_check = 0.0
var reminder_interval = 300.0  # Check every 5 minutes

func _ready():
	# Connect button signals with null checks
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if td_button:
		td_button.pressed.connect(_on_td_pressed)
	if settlement_button:
		settlement_button.pressed.connect(_on_settlement_pressed)
	if load_button:
		load_button.pressed.connect(_on_load_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	
	# Initialize test reminder system
	initialize_test_reminder_system()

func _on_play_pressed():
	print("Starting game flow...")
	# TODO: Implement proper game flow (later this will go through meta progression)
	# For now, go to settlement as starting point
	SceneManager.goto_settlement()

func _on_td_pressed():
	print("Starting Tower Defense (Direct Access)...")
	SceneManager.goto_tower_defense()

func _on_settlement_pressed():
	print("Opening Settlement (Direct Access)...")
	SceneManager.goto_settlement()

func _on_load_pressed():
	print("Opening Load Game...")
	show_load_dialog()

func _on_quit_pressed():
	get_tree().quit()

func show_load_dialog():
	"""Show load game dialog from main menu"""
	# Create load dialog
	var load_dialog = AcceptDialog.new()
	load_dialog.title = "Load Game"
	load_dialog.size = Vector2(500, 400)
	
	# Create scrollable list of save files
	var vbox = VBoxContainer.new()
	load_dialog.add_child(vbox)
	
	var label = Label.new()
	label.text = "Select save file to load:"
	vbox.add_child(label)
	
	var scroll_container = ScrollContainer.new()
	scroll_container.size = Vector2(450, 250)
	vbox.add_child(scroll_container)
	
	var save_list = VBoxContainer.new()
	scroll_container.add_child(save_list)
	
	# Get save files
	var save_files = GameManager.get_save_files()
	
	if save_files.is_empty():
		var no_saves_label = Label.new()
		no_saves_label.text = "No save files found"
		save_list.add_child(no_saves_label)
	else:
		for save_name in save_files:
			var save_info = GameManager.get_save_file_info(save_name)
			var save_button = Button.new()
			
			# Format save info
			var timestamp = Time.get_datetime_string_from_unix_time(save_info.get("timestamp", 0))
			var honey = save_info.get("honey", 0)
			var level = save_info.get("player_level", 1)
			
			save_button.text = save_name + " - Level " + str(level) + " - " + str(honey) + " Honey - " + timestamp
			save_button.pressed.connect(func(): _load_save_file(save_name, load_dialog))
			save_list.add_child(save_button)
	
	# Create buttons
	var button_container = HBoxContainer.new()
	vbox.add_child(button_container)
	
	var cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(load_dialog.queue_free)
	button_container.add_child(cancel_button)
	
	# Add to scene
	var ui_canvas = $UI
	ui_canvas.add_child(load_dialog)
	
	# Center the dialog
	var window_size = Vector2(get_viewport().get_visible_rect().size)
	load_dialog.position = (window_size - Vector2(load_dialog.size)) / 2

func _load_save_file(save_name: String, dialog: AcceptDialog):
	"""Load specified save file from main menu"""
	var success = GameManager.load_game(save_name)
	if success:
		print("Game loaded: " + save_name)
		dialog.queue_free()
		# Navigate to the appropriate scene based on save data
		# For now, go to tower defense
		SceneManager.goto_tower_defense()
	else:
		print("Failed to load game: " + save_name)
		# Show error message
		show_load_error("Failed to load game: " + save_name)

func show_load_error(message: String):
	"""Show load error notification"""
	var error_dialog = AcceptDialog.new()
	error_dialog.title = "Load Error"
	error_dialog.dialog_text = message
	error_dialog.size = Vector2(300, 100)
	
	# Add to scene
	var ui_canvas = $UI
	ui_canvas.add_child(error_dialog)
	
	# Center the dialog
	var window_size = Vector2(get_viewport().get_visible_rect().size)
	error_dialog.position = (window_size - Vector2(error_dialog.size)) / 2

# =============================================================================
# TEST REMINDER SYSTEM FUNCTIONS
# =============================================================================

func initialize_test_reminder_system():
	"""Initialize the test reminder system"""
	if test_reminder_enabled:
		print("🧪 Test reminder system initialized")
		check_for_pending_test_updates()

func _process(delta):
	"""Check for test reminders periodically"""
	if test_reminder_enabled:
		last_reminder_check += delta
		if last_reminder_check >= reminder_interval:
			check_for_pending_test_updates()
			last_reminder_check = 0.0

func check_for_pending_test_updates():
	"""Check if there are pending test updates"""
	if pending_test_updates.size() > 0:
		show_test_reminder()

func show_test_reminder():
	"""Show reminder to update tests"""
	print("\n" + "=".repeat(60))
	print("🧪 TEST UPDATE REMINDER")
	print("=".repeat(60))
	print("The following features need test updates:")
	
	for feature in pending_test_updates:
		print("  - %s" % feature)
	
	print("\nPlease update the test framework for these features!")
	print("=".repeat(60))

func add_new_feature(feature_name: String, description: String, required_tests: Array[String]):
	"""Add a new feature that needs testing"""
	pending_test_updates.append(feature_name)
	
	# Add to test coverage
	test_coverage[feature_name] = {
		"description": description,
		"tests": required_tests,
		"last_updated": Time.get_datetime_string_from_system()
	}
	
	print("📝 Added new feature '%s' - tests required!" % feature_name)
	show_test_reminder()

func mark_feature_tested(feature_name: String):
	"""Mark a feature as tested"""
	if feature_name in pending_test_updates:
		pending_test_updates.erase(feature_name)
		print("✅ Feature '%s' tests completed!" % feature_name)
	
	# Update last_updated timestamp
	if feature_name in test_coverage:
		test_coverage[feature_name]["last_updated"] = Time.get_datetime_string_from_system()

func get_test_coverage_status():
	"""Get current test coverage status"""
	var status = {
		"total_features": test_coverage.size(),
		"pending_updates": pending_test_updates.size(),
		"coverage_percentage": 0.0
	}
	
	if test_coverage.size() > 0:
		status.coverage_percentage = (float(test_coverage.size() - pending_test_updates.size()) / test_coverage.size()) * 100
	
	return status

func print_test_coverage_report():
	"""Print a detailed test coverage report"""
	print("\n" + "=".repeat(60))
	print("📊 TEST COVERAGE REPORT")
	print("=".repeat(60))
	
	var status = get_test_coverage_status()
	print("Total Features: %d" % status.total_features)
	print("Pending Updates: %d" % status.pending_updates)
	print("Coverage: %.1f%%" % status.coverage_percentage)
	
	print("\nFeature Details:")
	for feature_name in test_coverage.keys():
		var feature = test_coverage[feature_name]
		var status_icon = "✅" if feature_name not in pending_test_updates else "❌"
		print("  %s %s: %s" % [status_icon, feature_name, feature.description])
		print("    Tests: %s" % feature.tests)
		print("    Last Updated: %s" % feature.last_updated)
	
	print("=".repeat(60))

# =============================================================================
# MANUAL TEST MANAGEMENT
# =============================================================================

func enable_test_reminders():
	"""Enable test reminders"""
	test_reminder_enabled = true
	print("🔔 Test reminders enabled")

func disable_test_reminders():
	"""Disable test reminders"""
	test_reminder_enabled = false
	print("🔕 Test reminders disabled")

func set_reminder_interval(seconds: float):
	"""Set reminder check interval"""
	reminder_interval = seconds
	print("⏱️ Reminder interval set to %.1f seconds" % seconds)

# =============================================================================
# QUICK TEST HELPERS
# =============================================================================

func quick_test_new_tower_type(tower_name: String):
	"""Quick helper for testing new tower types"""
	add_new_feature(
		"tower_" + tower_name.to_lower(),
		"New tower type: " + tower_name,
		["tower_placement", "tower_attacks", "tower_upgrades"]
	)

func quick_test_new_enemy_type(enemy_name: String):
	"""Quick helper for testing new enemy types"""
	add_new_feature(
		"enemy_" + enemy_name.to_lower(),
		"New enemy type: " + enemy_name,
		["enemy_spawning", "enemy_movement", "enemy_health"]
	)

func quick_test_new_ui_feature(feature_name: String):
	"""Quick helper for testing new UI features"""
	add_new_feature(
		"ui_" + feature_name.to_lower(),
		"New UI feature: " + feature_name,
		["button_functionality", "ui_interaction", "ui_responsiveness"]
	)

# Mark completed features for new tower implementation
func mark_lightning_flower_testing_complete():
	"""Mark Lightning Flower implementation as tested"""
	mark_feature_tested("tower_lightning_flower")
	mark_feature_tested("tower_click_interaction")
	mark_feature_tested("range_indicators")
	mark_feature_tested("tower_selection_safety")
	print("✅ Lightning Flower testing marked as complete")