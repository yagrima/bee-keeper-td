extends Control

@onready var back_button = $UI/Header/BackButton
@onready var hive_spot = $UI/BuildingSpots/HiveSpot
@onready var workshop_spot = $UI/BuildingSpots/WorkshopSpot
@onready var port_spot = $UI/BuildingSpots/PortSpot
@onready var barracks_spot = $UI/BuildingSpots/BarracksSpot

func _ready():
	# Connect button signals with null checks
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	if hive_spot:
		hive_spot.pressed.connect(_on_hive_pressed)
	if workshop_spot:
		workshop_spot.pressed.connect(_on_workshop_pressed)
	if port_spot:
		port_spot.pressed.connect(_on_port_pressed)
	if barracks_spot:
		barracks_spot.pressed.connect(_on_barracks_pressed)

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