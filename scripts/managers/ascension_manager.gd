class_name AscensionManager
extends RefCounted
## Handles ascension and soul shop logic

const UpgradeData = preload("res://scripts/data/upgrade_data.gd")

var game_state

const THRESHOLD: float = 100000.0
const WEAPON_UPGRADE_BASE_COST: int = 3
const WEAPON_UPGRADE_COST_MULT: float = 1.5

# Soul upgrade scaling - exponential to prevent trivial late-game
const SOUL_UPGRADE_COST_MULT: float = 1.8


func _init(state) -> void:
	game_state = state


func can_ascend() -> bool:
	return game_state.total_gold_earned >= THRESHOLD


func get_souls_on_ascension() -> int:
	return int(sqrt(game_state.total_gold_earned / 10000.0))


func get_ascension_bonus() -> float:
	var bonus = 1.0
	bonus += game_state.ascension_upgrades.get("soul_power", 0) * 0.10
	bonus += game_state.ascension_upgrades.get("soul_income", 0) * 0.10
	bonus += game_state.ancient_souls * 0.01
	return bonus


func ascend() -> int:
	if not can_ascend():
		return 0
	
	var souls_earned = get_souls_on_ascension()
	game_state.ancient_souls += souls_earned
	game_state.total_ascensions += 1
	game_state.lifetime_gold += game_state.total_gold_earned
	
	# Reset progress
	game_state.gold = 0.0
	game_state.total_gold_earned = 0.0
	game_state.click_power = 1.0
	game_state.passive_income = 0.0
	game_state.auto_forge_rate = 0.0
	game_state.unlocked_tier = 0
	
	for key in game_state.items_forged:
		game_state.items_forged[key] = 0
	game_state.total_items_forged = 0
	
	for key in game_state.upgrades:
		game_state.upgrades[key] = 0
	
	game_state.highest_gold_ever = 0.0
	game_state.discovered_upgrades.clear()
	
	# Apply ascension bonus to starting click power
	game_state.click_power *= get_ascension_bonus()
	
	GameEvents.ascended.emit(souls_earned)
	return souls_earned


# Soul Shop - Soul Upgrades
func get_soul_upgrade_cost(upgrade_id: String) -> int:
	var data = UpgradeData.get_soul_upgrade(upgrade_id)
	var level = game_state.ascension_upgrades.get(upgrade_id, 0)
	var base_cost = data.get("base_cost", 1)
	# Exponential scaling: base_cost * 1.8^level
	return int(base_cost * pow(SOUL_UPGRADE_COST_MULT, level))


func can_afford_soul_upgrade(upgrade_id: String) -> bool:
	return game_state.ancient_souls >= get_soul_upgrade_cost(upgrade_id)


func purchase_soul_upgrade(upgrade_id: String) -> bool:
	var cost = get_soul_upgrade_cost(upgrade_id)
	if game_state.ancient_souls < cost:
		return false
	
	game_state.ancient_souls -= cost
	game_state.ascension_upgrades[upgrade_id] = game_state.ascension_upgrades.get(upgrade_id, 0) + 1
	GameEvents.soul_upgrade_purchased.emit(upgrade_id)
	return true


# Soul Shop - Weapon Upgrades
func get_weapon_upgrade_cost(weapon_id: String) -> int:
	var level = game_state.weapon_upgrade_levels.get(weapon_id, 0)
	return int(WEAPON_UPGRADE_BASE_COST * pow(WEAPON_UPGRADE_COST_MULT, level))


func can_afford_weapon_upgrade(weapon_id: String, forge_manager) -> bool:
	if not forge_manager.is_weapon_unlocked(weapon_id):
		return false
	return game_state.ancient_souls >= get_weapon_upgrade_cost(weapon_id)


func purchase_weapon_upgrade(weapon_id: String, forge_manager) -> bool:
	if not forge_manager.is_weapon_unlocked(weapon_id):
		return false
	
	var cost = get_weapon_upgrade_cost(weapon_id)
	if game_state.ancient_souls < cost:
		return false
	
	game_state.ancient_souls -= cost
	game_state.weapon_upgrade_levels[weapon_id] = game_state.weapon_upgrade_levels.get(weapon_id, 0) + 1
	# Each level gives +25% to weapon multiplier
	game_state.weapon_multipliers[weapon_id] = 1.0 + (game_state.weapon_upgrade_levels[weapon_id] * 0.25)
	
	GameEvents.weapon_upgrade_purchased.emit(weapon_id)
	return true
