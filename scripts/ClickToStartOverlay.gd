extends Control
## ClickToStartOverlay - DEPRECATED - Now handled by HTML overlay
## This Godot overlay doesn't work because Godot input system is inactive until user clicks

func _ready():
	# HTML overlay handles this now - just remove this Godot version
	queue_free()
