extends Node
class_name TDSaveSystem

# Tower Defense Save/Load System
# Handles automatic save/load with cloud-first strategy

var td_scene: Node  # Reference to main TowerDefense scene

func _init(scene: Node):
	td_scene = scene

# =============================================================================
# AUTO-SAVE / AUTO-LOAD SYSTEM
# =============================================================================

func auto_load_game():
	"""
	Automatically load game when entering Tower Defense
	Tries cloud first, then local fallback
	"""
	print("🔄 Auto-loading game data...")

	if SupabaseClient.is_authenticated() and SaveManager.CLOUD_SYNC_ENABLED:
		print("☁️ Loading from cloud...")
		var success = await SaveManager.load_from_cloud()
		if success:
			print("✅ Cloud data loaded successfully")
			return
		else:
			print("⚠️ Cloud load failed, trying local...")

	# Fallback to local save
	if SaveManager.save_file_exists("main"):
		var success = await SaveManager.load_game("main")
		if success:
			print("✅ Local data loaded successfully")
		else:
			print("ℹ️ No save data found, starting fresh")
	else:
		print("ℹ️ No save data found, starting fresh")

func auto_save_game(reason: String = "Auto-save"):
	"""
	Automatically save game with cloud sync
	Called after each wave and on exit
	"""
	print("💾 Auto-saving: %s" % reason)
	SaveManager.save_game("main")

func check_for_pending_save_data():
	"""Check if there's pending save data to load"""
	if SaveManager.has_pending_tower_defense_data():
		var save_data = SaveManager.get_pending_tower_defense_data()
		load_tower_defense_data(save_data)
		print("Loaded pending tower defense save data")

# =============================================================================
# DATA COLLECTION & APPLICATION
# =============================================================================

func get_tower_defense_data() -> Dictionary:
	"""Get current tower defense scene data for saving"""
	var tower_data = []

	# Get tower data from tower placer
	if td_scene.tower_placer:
		var placed_towers = td_scene.tower_placer.get_placed_towers()
		for tower in placed_towers:
			if tower and is_instance_valid(tower):
				tower_data.append({
					"type": tower.tower_name,
					"position": {
						"x": tower.global_position.x,
						"y": tower.global_position.y
					},
					"level": tower.level,
					"damage": tower.damage,
					"range": tower.range,
					"attack_speed": tower.attack_speed,
					"honey_cost": tower.honey_cost,
					"upgrade_cost": tower.get_upgrade_cost()
				})

	# Get wave data
	var wave_data = {}
	if td_scene.wave_manager:
		wave_data = {
			"current_wave": td_scene.wave_manager.get_current_wave(),
			"is_wave_active": td_scene.wave_manager.is_wave_in_progress(),
			"wave_progress": td_scene.wave_manager.get_wave_progress()
		}

	return {
		"current_wave": td_scene.current_wave,
		"player_health": td_scene.player_health,
		"honey": GameManager.get_resource("honey"),
		"placed_towers": tower_data,
		"wave_data": wave_data,
		"current_tower_type": td_scene.current_tower_type
	}

func load_tower_defense_data(data: Dictionary):
	"""Load tower defense scene data from save"""
	if data.has("current_wave"):
		td_scene.current_wave = data["current_wave"]
	if data.has("player_health"):
		td_scene.player_health = data["player_health"]
	if data.has("honey"):
		# Set honey resource
		var current_honey = GameManager.get_resource("honey")
		var honey_diff = data["honey"] - current_honey
		if honey_diff != 0:
			GameManager.add_resource("honey", honey_diff)
	if data.has("current_tower_type"):
		td_scene.current_tower_type = data["current_tower_type"]

	# Load towers
	if data.has("placed_towers") and td_scene.tower_placer:
		load_placed_towers(data["placed_towers"])

	# Load wave data
	if data.has("wave_data") and td_scene.wave_manager:
		load_wave_data(data["wave_data"])

	# Update UI
	td_scene.update_ui()

func load_placed_towers(tower_data: Array):
	"""Load placed towers from save data"""
	# Clear existing towers
	if td_scene.tower_placer:
		var existing_towers = td_scene.tower_placer.get_placed_towers()
		for tower in existing_towers:
			if tower and is_instance_valid(tower):
				tower.queue_free()
		td_scene.tower_placer.placed_towers.clear()

	# Place saved towers
	for tower_info in tower_data:
		place_tower_from_save(tower_info)

func place_tower_from_save(tower_info: Dictionary):
	"""Place a tower from save data"""
	var tower_type = tower_info.get("type", "basic_shooter")
	var position = Vector2(tower_info.get("position", {}).get("x", 0), tower_info.get("position", {}).get("y", 0))

	# Create tower instance
	var tower_script = null
	match tower_type:
		"stinger":
			tower_script = load("res://scripts/StingerTower.gd")
		"propolis_bomber":
			tower_script = load("res://scripts/PropolisBomberTower.gd")
		"nectar_sprayer":
			tower_script = load("res://scripts/NectarSprayerTower.gd")
		"lightning_flower":
			tower_script = load("res://scripts/LightningFlowerTower.gd")
		_:
			print("Unknown tower type in save: ", tower_type)
			return

	if tower_script:
		var tower = tower_script.new() as Tower

		# Set tower properties
		if tower_info.has("level"):
			tower.level = tower_info["level"]
		if tower_info.has("damage"):
			tower.damage = tower_info["damage"]
		if tower_info.has("range"):
			tower.range = tower_info["range"]
		if tower_info.has("attack_speed"):
			tower.attack_speed = tower_info["attack_speed"]
		if tower_info.has("honey_cost"):
			tower.honey_cost = tower_info["honey_cost"]
		if tower_info.has("upgrade_cost"):
			tower.upgrade_cost = tower_info["upgrade_cost"]

		# Position tower
		tower.global_position = position

		# Add to scene
		var ui_canvas = td_scene.get_node("UI")
		ui_canvas.add_child(tower)

		# Add to tower placer
		if td_scene.tower_placer:
			td_scene.tower_placer.placed_towers.append(tower)
			tower.tower_destroyed.connect(td_scene.tower_placer._on_tower_destroyed)

		print("Loaded tower: ", tower_type, " at ", position)

func load_wave_data(wave_data: Dictionary):
	"""Load wave data from save"""
	if td_scene.wave_manager and wave_data.has("current_wave"):
		# Set wave number but don't start the wave
		td_scene.current_wave = wave_data["current_wave"]
		# Note: We don't restore active waves to avoid complications
		print("Loaded wave data: Wave ", td_scene.current_wave)