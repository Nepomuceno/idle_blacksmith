class_name SaveManager
extends RefCounted
## Handles save/load operations

const SAVE_PATH = "user://savegame.save"
const MAX_OFFLINE_HOURS: float = 8.0
const OFFLINE_EFFICIENCY: float = 0.5

var game_state


func _init(state) -> void:
	game_state = state


func save() -> void:
	game_state.last_save_timestamp = Time.get_unix_time_from_system()
	
	var save_data = {
		"gold": game_state.gold,
		"total_gold_earned": game_state.total_gold_earned,
		"highest_gold_ever": game_state.highest_gold_ever,
		"lifetime_gold": game_state.lifetime_gold,
		"ancient_souls": game_state.ancient_souls,
		"total_ascensions": game_state.total_ascensions,
		"forge_level": game_state.forge_level,
		"click_power": game_state.click_power,
		"passive_income": game_state.passive_income,
		"auto_forge_rate": game_state.auto_forge_rate,
		"selected_weapon": game_state.selected_weapon,
		"weapon_multipliers": game_state.weapon_multipliers,
		"weapon_upgrade_levels": game_state.weapon_upgrade_levels,
		"items_forged": game_state.items_forged,
		"total_items_forged": game_state.total_items_forged,
		"unlocked_tier": game_state.unlocked_tier,
		"upgrades": game_state.upgrades,
		"discovered_upgrades": game_state.discovered_upgrades,
		"ascension_upgrades": game_state.ascension_upgrades,
		"unlocked_achievements": game_state.unlocked_achievements,
		"pending_achievement_rewards": game_state.pending_achievement_rewards,
		"last_save_timestamp": game_state.last_save_timestamp
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		GameEvents.game_saved.emit()


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_string) != OK:
		return false
	
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		return false
	
	# Load all values with defaults
	game_state.gold = data.get("gold", 0.0)
	game_state.total_gold_earned = data.get("total_gold_earned", 0.0)
	game_state.highest_gold_ever = data.get("highest_gold_ever", 0.0)
	game_state.lifetime_gold = data.get("lifetime_gold", 0.0)
	game_state.ancient_souls = data.get("ancient_souls", 0)
	game_state.total_ascensions = data.get("total_ascensions", 0)
	game_state.forge_level = data.get("forge_level", 1)
	game_state.click_power = data.get("click_power", 1.0)
	game_state.passive_income = data.get("passive_income", 0.0)
	game_state.auto_forge_rate = data.get("auto_forge_rate", 0.0)
	game_state.selected_weapon = data.get("selected_weapon", "sword")
	game_state.unlocked_tier = data.get("unlocked_tier", 0)
	game_state.total_items_forged = data.get("total_items_forged", 0)
	game_state.pending_achievement_rewards = data.get("pending_achievement_rewards", 0.0)
	game_state.last_save_timestamp = data.get("last_save_timestamp", 0.0)
	
	# Load dictionaries
	if data.has("weapon_multipliers"):
		for key in data["weapon_multipliers"]:
			game_state.weapon_multipliers[key] = data["weapon_multipliers"][key]
	
	if data.has("weapon_upgrade_levels"):
		for key in data["weapon_upgrade_levels"]:
			game_state.weapon_upgrade_levels[key] = data["weapon_upgrade_levels"][key]
	
	if data.has("items_forged"):
		for key in data["items_forged"]:
			game_state.items_forged[key] = data["items_forged"][key]
	
	if data.has("upgrades"):
		for key in data["upgrades"]:
			game_state.upgrades[key] = data["upgrades"][key]
	
	if data.has("ascension_upgrades"):
		for key in data["ascension_upgrades"]:
			game_state.ascension_upgrades[key] = data["ascension_upgrades"][key]
	
	if data.has("discovered_upgrades"):
		game_state.discovered_upgrades = data["discovered_upgrades"]
	
	if data.has("unlocked_achievements"):
		game_state.unlocked_achievements = data["unlocked_achievements"]
	
	GameEvents.game_loaded.emit()
	return true


func calculate_offline_progress() -> Dictionary:
	if game_state.last_save_timestamp <= 0:
		return {"gold": 0.0, "seconds": 0.0}
	
	if game_state.passive_income <= 0 and game_state.auto_forge_rate <= 0:
		return {"gold": 0.0, "seconds": 0.0}
	
	var current_time = Time.get_unix_time_from_system()
	var elapsed_seconds = current_time - game_state.last_save_timestamp
	
	var max_seconds = MAX_OFFLINE_HOURS * 3600.0
	elapsed_seconds = minf(elapsed_seconds, max_seconds)
	
	if elapsed_seconds < 60:
		return {"gold": 0.0, "seconds": 0.0}
	
	var ascension_bonus = 1.0 + game_state.ancient_souls * 0.01
	
	# Calculate offline gold from passive income
	var offline_gold = game_state.passive_income * elapsed_seconds * OFFLINE_EFFICIENCY * ascension_bonus
	
	# Add gold from auto-forge (at reduced efficiency)
	var auto_forge_bonus = 1.0 + (game_state.ascension_upgrades.get("soul_forge", 0) * 0.10)
	var effective_auto_rate = game_state.auto_forge_rate * auto_forge_bonus
	var auto_forge_gold = effective_auto_rate * elapsed_seconds * OFFLINE_EFFICIENCY * game_state.click_power * ascension_bonus
	offline_gold += auto_forge_gold
	
	return {"gold": offline_gold, "seconds": elapsed_seconds}


func apply_offline_progress(offline_gold: float) -> void:
	if offline_gold > 0:
		game_state.gold += offline_gold
		game_state.total_gold_earned += offline_gold
		if game_state.gold > game_state.highest_gold_ever:
			game_state.highest_gold_ever = game_state.gold
		GameEvents.gold_changed.emit(game_state.gold)


func reset_all() -> void:
	game_state.reset()
	
	# Delete save file
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	
	GameEvents.game_reset.emit()
