class_name ForgeManager
extends RefCounted
## Handles forging logic and calculations

const TierData = preload("res://scripts/data/tier_data.gd")
const WeaponData = preload("res://scripts/data/weapon_data.gd")

var game_state


func _init(state) -> void:
	game_state = state


func forge() -> Dictionary:
	var weapon_id = game_state.selected_weapon
	var tier = _roll_tier()
	var tier_data = TierData.get_tier(tier)
	var value = _calculate_forge_value(weapon_id, tier)
	
	# Update state
	game_state.items_forged[weapon_id] = game_state.items_forged.get(weapon_id, 0) + 1
	game_state.total_items_forged += 1
	game_state.add_gold(value)
	
	# Check tier unlocks
	_check_tier_unlocks()
	
	return {
		"weapon_id": weapon_id,
		"tier": tier,
		"tier_name": tier_data.get("name", "Common"),
		"tier_color": tier_data.get("color", Color.WHITE),
		"value": value
	}


func _roll_tier() -> int:
	var luck_bonus = game_state.ascension_upgrades.get("soul_luck", 0) * 0.05
	return TierData.roll_tier(game_state.unlocked_tier, luck_bonus)


func _calculate_forge_value(weapon_id: String, tier: int) -> float:
	var base_value = WeaponData.get_base_value(weapon_id)
	var weapon_mult = game_state.weapon_multipliers.get(weapon_id, 1.0)
	var tier_mult = TierData.get_tier_multiplier(tier)
	var click_power = game_state.click_power
	
	return base_value * weapon_mult * tier_mult * click_power


func _check_tier_unlocks() -> void:
	var new_tier = TierData.get_max_tier_for_forged(game_state.total_items_forged)
	if new_tier > game_state.unlocked_tier:
		game_state.unlocked_tier = new_tier


func get_weapon_value(weapon_id: String) -> float:
	var base = WeaponData.get_base_value(weapon_id)
	var weapon_mult = game_state.weapon_multipliers.get(weapon_id, 1.0)
	return base * weapon_mult * game_state.click_power


func get_effective_auto_forge_rate() -> float:
	var soul_bonus = 1.0 + (game_state.ascension_upgrades.get("soul_forge", 0) * 0.10)
	return game_state.auto_forge_rate * soul_bonus


func select_weapon(weapon_id: String) -> bool:
	if is_weapon_unlocked(weapon_id):
		game_state.selected_weapon = weapon_id
		return true
	return false


func is_weapon_unlocked(weapon_id: String) -> bool:
	var required = WeaponData.get_unlock_requirement(weapon_id)
	return game_state.total_ascensions >= required


func get_unlocked_weapons() -> Array:
	var unlocked = []
	for weapon_id in WeaponData.get_weapon_ids():
		if is_weapon_unlocked(weapon_id):
			unlocked.append(weapon_id)
	return unlocked
