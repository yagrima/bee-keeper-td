extends Control

@onready var play_button = $UI/MenuContainer/PlayButton
@onready var settlement_button = $UI/MenuContainer/SettlementButton
@onready var load_button = $UI/MenuContainer/LoadButton
@onready var quit_button = $UI/MenuContainer/QuitButton

func _ready():
	# Connect button signals with null checks
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if settlement_button:
		settlement_button.pressed.connect(_on_settlement_pressed)
	if load_button:
		load_button.pressed.connect(_on_load_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	print("Starting Tower Defense...")
	SceneManager.goto_tower_defense()

func _on_settlement_pressed():
	print("Opening Settlement...")
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
	var window_size = get_viewport().get_visible_rect().size
	load_dialog.position = (window_size - load_dialog.size) / 2

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
	var window_size = get_viewport().get_visible_rect().size
	error_dialog.position = (window_size - error_dialog.size) / 2