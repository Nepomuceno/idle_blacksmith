class_name UpgradeManager
extends RefCounted
## Handles upgrade purchasing and effects

const UpgradeData = preload("res://scripts/data/upgrade_data.gd")

var game_state


func _init(state) -> void:
	game_state = state


func get_cost(upgrade_id: String) -> float:
	var level = game_state.upgrades.get(upgrade_id, 0)
	return UpgradeData.calculate_cost(upgrade_id, level)


func get_effect(upgrade_id: String) -> float:
	var level = game_state.upgrades.get(upgrade_id, 0)
	return UpgradeData.calculate_effect(upgrade_id, level)


func is_maxed(upgrade_id: String) -> bool:
	var level = game_state.upgrades.get(upgrade_id, 0)
	return UpgradeData.is_maxed(upgrade_id, level)


func can_afford(upgrade_id: String) -> bool:
	return game_state.gold >= get_cost(upgrade_id)


func is_visible(upgrade_id: String) -> bool:
	# Already purchased = always visible
	if game_state.upgrades.get(upgrade_id, 0) > 0:
		return true
	
	# Already discovered = visible
	if upgrade_id in game_state.discovered_upgrades:
		return true
	
	# Check visibility threshold
	var data = UpgradeData.get_upgrade(upgrade_id)
	var base_cost = data.get("base_cost", 100.0)
	var visibility_threshold = data.get("visibility", 0.5)
	
	if game_state.highest_gold_ever >= base_cost * visibility_threshold:
		game_state.discovered_upgrades.append(upgrade_id)
		return true
	
	return false


func get_visible_upgrades() -> Array:
	var visible = []
	for upgrade_id in UpgradeData.get_upgrade_ids():
		if is_visible(upgrade_id) and not is_maxed(upgrade_id):
			visible.append(upgrade_id)
	return visible


func purchase(upgrade_id: String) -> bool:
	if is_maxed(upgrade_id):
		return false
	
	var cost = get_cost(upgrade_id)
	if game_state.gold < cost:
		return false
	
	game_state.gold -= cost
	game_state.upgrades[upgrade_id] = game_state.upgrades.get(upgrade_id, 0) + 1
	_apply_effect(upgrade_id)
	
	GameEvents.gold_changed.emit(game_state.gold)
	GameEvents.upgrade_purchased.emit(upgrade_id, game_state.upgrades[upgrade_id])
	
	return true


func _apply_effect(upgrade_id: String) -> void:
	var bonus = game_state.get_ascension_bonus()
	var effect = get_effect(upgrade_id)
	
	match upgrade_id:
		"better_anvil":
			game_state.click_power += effect * bonus
		"apprentice":
			game_state.passive_income += effect * bonus
		"auto_forge":
			game_state.auto_forge_rate += effect
		"master_smith":
			game_state.click_power += effect * bonus
			game_state.passive_income += (effect * 0.2) * bonus
		"enchanted_forge":
			game_state.click_power *= 1.5
			game_state.passive_income *= 1.5
			game_state.auto_forge_rate *= 1.5
		"golden_hammer":
			game_state.click_power += effect * bonus
		"forge_masters":
			game_state.auto_forge_rate += effect
		"mithril_tools":
			game_state.passive_income += effect * bonus
		"dragon_bellows":
			game_state.click_power *= 2.0
			game_state.passive_income *= 2.0
			game_state.auto_forge_rate *= 2.0
		"time_warp":
			game_state.click_power *= 3.0
			game_state.passive_income *= 3.0
			game_state.auto_forge_rate *= 3.0


func get_total_click_power() -> float:
	return game_state.click_power


func get_total_passive_income() -> float:
	return game_state.passive_income


func get_total_auto_forge_rate() -> float:
	return game_state.auto_forge_rate
