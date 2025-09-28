extends Control

@onready var play_button = $UI/MenuContainer/PlayButton
@onready var settlement_button = $UI/MenuContainer/SettlementButton
@onready var quit_button = $UI/MenuContainer/QuitButton

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	settlement_button.pressed.connect(_on_settlement_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	print("Starting Tower Defense...")
	SceneManager.goto_tower_defense()

func _on_settlement_pressed():
	print("Opening Settlement...")
	SceneManager.goto_settlement()

func _on_quit_pressed():
	get_tree().quit()