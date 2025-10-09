extends Control

func _ready():
	var tab_container = $TabContainer
	tab_container.tab_changed.connect(_on_tab_changed)
	print("TabContainer test ready - click the tabs!")
	
func _on_tab_changed(tab: int):
	print("Tab changed to: ", tab)
