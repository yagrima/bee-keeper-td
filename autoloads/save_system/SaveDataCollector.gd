class_name SaveDataCollector
extends RefCounted

# =============================================================================
# SAVE DATA COLLECTOR
# =============================================================================
# Collects save data from various game systems
# - Player data (resources, progress)
# - Tower Defense scene data
# - Hotkey configuration
# - Settlement/meta progression data
# =============================================================================

var tree: SceneTree

func _init(scene_tree: SceneTree):
	tree = scene_tree

func collect_all_save_data() -> Dictionary:
	"""Collect all game data that needs to be saved"""
	return {
		"version": "1.0",
		"timestamp": Time.get_unix_time_from_system(),
		"game_state": GameManager.current_state,
		"player_data": collect_player_data(),
		"hotkeys": collect_hotkey_data(),
		"tower_defense": collect_tower_defense_data(),
		"settlement": collect_settlement_data()
	}

func collect_player_data() -> Dictionary:
	"""Collect player data from GameManager"""
	return {
		"account_level": GameManager.player_data.account_level,
		"honey": GameManager.player_data.honey,
		"honeygems": GameManager.player_data.honeygems,
		"wax": GameManager.player_data.wax,
		"wood": GameManager.player_data.wood,
		"buildings": GameManager.player_data.buildings.duplicate(),
		"towers": GameManager.player_data.towers.duplicate(),
		"soldiers": GameManager.player_data.soldiers.duplicate()
	}

func collect_hotkey_data() -> Dictionary:
	"""Collect hotkey configuration"""
	return HotkeyManager.get_all_hotkeys()

func collect_tower_defense_data() -> Dictionary:
	"""Collect tower defense scene data"""
	var td_data = {
		"current_wave": 1,
		"player_health": 20,
		"placed_towers": [],
		"wave_progress": {}
	}
	
	# Try to get data from current tower defense scene
	var current_scene = tree.current_scene
	if current_scene and current_scene.has_method("get_tower_defense_data"):
		td_data = current_scene.get_tower_defense_data()
	elif current_scene and current_scene.name == "TowerDefense":
		# Fallback: try to get data from scene nodes
		td_data = get_tower_defense_data_from_scene(current_scene)
	
	return td_data

func get_tower_defense_data_from_scene(scene: Node) -> Dictionary:
	"""Extract tower defense data from scene nodes"""
	var td_data = {
		"current_wave": 1,
		"player_health": 20,
		"placed_towers": [],
		"wave_progress": {}
	}
	
	# Try to get data from scene variables
	if scene.has_method("get") and scene.get("current_wave"):
		td_data["current_wave"] = scene.get("current_wave")
	if scene.has_method("get") and scene.get("player_health"):
		td_data["player_health"] = scene.get("player_health")
	
	# Try to get tower placer data
	var tower_placer = scene.get_node_or_null("TowerPlacer")
	if tower_placer and tower_placer.has_method("get_placed_towers"):
		var towers = tower_placer.get_placed_towers()
		for tower in towers:
			if tower and is_instance_valid(tower):
				td_data["placed_towers"].append({
					"type": tower.tower_name,
					"position": {
						"x": tower.global_position.x,
						"y": tower.global_position.y
					},
					"level": tower.level,
					"damage": tower.damage,
					"range": tower.range,
					"attack_speed": tower.attack_speed
				})
	
	# Try to get wave manager data
	var wave_manager = scene.get_node_or_null("WaveManager")
	if wave_manager and wave_manager.has_method("get_current_wave"):
		td_data["current_wave"] = wave_manager.get_current_wave()
	
	return td_data

func collect_settlement_data() -> Dictionary:
	"""Collect settlement/meta progression data"""
	return {
		"buildings_unlocked": [],
		"upgrades_purchased": [],
		"settlement_level": 1
	}
