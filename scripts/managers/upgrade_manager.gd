class_name UpgradeManager
extends RefCounted
## Handles upgrade purchasing and effects

const UpgradeData = preload("res://scripts/data/upgrade_data.gd")

# Diminishing returns for multipliers - each subsequent multiplier is less effective
# Formula: effective_mult = 1 + (base_mult - 1) * MULTIPLIER_DIMINISH^total_purchased
const MULTIPLIER_DIMINISH: float = 0.75

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
	var found_unaffordable = false
	
	# Get all upgrades sorted by base cost
	var all_upgrades = UpgradeData.get_upgrade_ids()
	var sorted_upgrades = []
	for upgrade_id in all_upgrades:
		var data = UpgradeData.get_upgrade(upgrade_id)
		sorted_upgrades.append({"id": upgrade_id, "cost": data.get("base_cost", 0.0)})
	sorted_upgrades.sort_custom(func(a, b): return a.cost < b.cost)
	
	for item in sorted_upgrades:
		var upgrade_id = item.id
		if is_maxed(upgrade_id):
			continue
		
		if is_visible(upgrade_id):
			visible.append(upgrade_id)
			if not can_afford(upgrade_id):
				found_unaffordable = true
		elif not found_unaffordable:
			# Show the next upgrade we haven't discovered yet (teaser)
			visible.append(upgrade_id)
			found_unaffordable = true
	
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
	var data = UpgradeData.get_upgrade(upgrade_id)
	var effect_type = data.get("effect_type", "")
	
	match effect_type:
		"click_power":
			game_state.click_power += effect * bonus
		"passive_income":
			game_state.passive_income += effect * bonus
		"auto_forge":
			game_state.auto_forge_rate += effect
		"combo":
			game_state.click_power += effect * bonus
			game_state.passive_income += (effect * 0.2) * bonus
		"multiplier":
			# Apply diminishing returns based on total multipliers already purchased
			var base_multiplier = _get_multiplier_value(upgrade_id)
			var effective_multiplier = get_effective_multiplier(base_multiplier)
			
			game_state.click_power *= effective_multiplier
			game_state.passive_income *= effective_multiplier
			game_state.auto_forge_rate *= effective_multiplier
			
			# Track that we purchased another multiplier
			game_state.total_multipliers_purchased += 1


## Calculate effective multiplier after diminishing returns
## Formula: 1 + (base - 1) * 0.75^total_purchased
func get_effective_multiplier(base_multiplier: float) -> float:
	var diminish_factor = pow(MULTIPLIER_DIMINISH, game_state.total_multipliers_purchased)
	return 1.0 + (base_multiplier - 1.0) * diminish_factor


## Get the effective multiplier for display purposes (what player will get if they buy)
func get_preview_multiplier(upgrade_id: String) -> float:
	var base_multiplier = _get_multiplier_value(upgrade_id)
	return get_effective_multiplier(base_multiplier)


func _get_multiplier_value(upgrade_id: String) -> float:
	match upgrade_id:
		"enchanted_forge":
			return 1.5
		"dragon_bellows":
			return 2.0
		"runic_enchantment":
			return 1.5
		"time_warp":
			return 3.0
		"arcane_anvil":
			return 2.0
		"ancient_blessing":
			return 5.0
		"celestial_smithy":
			return 10.0
		"divine_anvil":
			return 25.0
		"cosmic_forge":
			return 100.0
		_:
			return 1.0


func get_total_click_power() -> float:
	return game_state.click_power


func get_total_passive_income() -> float:
	return game_state.passive_income


func get_total_auto_forge_rate() -> float:
	return game_state.auto_forge_rate
