extends Control

@onready var back_button = $UI/Header/BackButton
@onready var hive_button = $UI/BuildingContainer/HiveSpot/HiveButton
@onready var workshop_button = $UI/BuildingContainer/WorkshopSpot/WorkshopButton
@onready var port_button = $UI/BuildingContainer/PortSpot/PortButton
@onready var barracks_button = $UI/BuildingContainer/BarracksSpot/BarracksButton

func _ready():
	# Connect button signals with null checks
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	if hive_button:
		hive_button.pressed.connect(_on_hive_pressed)
	if workshop_button:
		workshop_button.pressed.connect(_on_workshop_pressed)
	if port_button:
		port_button.pressed.connect(_on_port_pressed)
	if barracks_button:
		barracks_button.pressed.connect(_on_barracks_pressed)

func _on_back_pressed():
	SceneManager.goto_main_menu()

func _on_hive_pressed():
	print("Opening The Hive...")
	# TODO: Implement Hive building interface

func _on_workshop_pressed():
	print("Opening Workshop...")
	# TODO: Implement Workshop building interface

func _on_port_pressed():
	print("Opening The Port...")
	# TODO: Implement Port building interface

func _on_barracks_pressed():
	print("Opening Barracks...")
	# TODO: Implement Barracks building interface