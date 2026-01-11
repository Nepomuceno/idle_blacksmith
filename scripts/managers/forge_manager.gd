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
	
	# Check for critical forge
	var is_crit = randf() < game_state.get_effective_crit_chance()
	if is_crit:
		value *= game_state.CRIT_MULTIPLIER
	game_state.last_forge_was_crit = is_crit
	
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
		"value": value,
		"is_crit": is_crit
	}


## Bulk forge for high auto-forge rates - calculates expected value instead of rolling each
func bulk_forge(count: int) -> Dictionary:
	if count <= 0:
		return {"total_value": 0.0, "best_tier": 0, "best_tier_color": Color.WHITE}
	
	var weapon_id = game_state.selected_weapon
	var luck_bonus = game_state.ascension_upgrades.get("soul_luck", 0) * 0.05
	var unlocked_tier = game_state.unlocked_tier
	
	# Calculate tier probabilities
	var tier_probs = _get_tier_probabilities(unlocked_tier, luck_bonus)
	
	# Calculate expected value per forge
	var expected_value_per_forge = 0.0
	for tier in range(tier_probs.size()):
		var tier_value = _calculate_forge_value(weapon_id, tier)
		expected_value_per_forge += tier_probs[tier] * tier_value
	
	var total_value = expected_value_per_forge * count
	
	# Update state
	game_state.items_forged[weapon_id] = game_state.items_forged.get(weapon_id, 0) + count
	game_state.total_items_forged += count
	game_state.add_gold(total_value)
	
	# Check tier unlocks
	_check_tier_unlocks()
	
	# Determine best tier for visual (probabilistic based on count)
	var best_tier = _sample_best_tier(count, tier_probs, unlocked_tier)
	var tier_data = TierData.get_tier(best_tier)
	
	return {
		"total_value": total_value,
		"best_tier": best_tier,
		"best_tier_color": tier_data.get("color", Color.WHITE),
		"count": count
	}


func _get_tier_probabilities(unlocked_tier: int, luck_bonus: float) -> Array:
	# Calculate actual probability for each tier
	# DROP_THRESHOLDS = [0.0, 0.65, 0.85, 0.95, 0.99]
	var probs = [0.0, 0.0, 0.0, 0.0, 0.0]
	
	# Clamp luck_bonus effect
	var effective_luck = minf(luck_bonus, 0.3)
	
	# Probability of tier 4 (Legendary): roll > 0.99
	if unlocked_tier >= 4:
		probs[4] = (1.0 - 0.99) + effective_luck * 0.2
	
	# Probability of tier 3 (Epic): roll > 0.95 but <= 0.99
	if unlocked_tier >= 3:
		probs[3] = (0.99 - 0.95) + effective_luck * 0.3
	
	# Probability of tier 2 (Rare): roll > 0.85 but <= 0.95
	if unlocked_tier >= 2:
		probs[2] = (0.95 - 0.85) + effective_luck * 0.5
	
	# Probability of tier 1 (Uncommon): roll > 0.65 but <= 0.85
	if unlocked_tier >= 1:
		probs[1] = (0.85 - 0.65) + effective_luck * 0.5
	
	# Tier 0 (Common) is the remainder
	var higher_prob = probs[1] + probs[2] + probs[3] + probs[4]
	probs[0] = maxf(1.0 - higher_prob, 0.1)
	
	# Normalize
	var total = 0.0
	for p in probs:
		total += p
	for i in range(probs.size()):
		probs[i] /= total
	
	return probs


func _sample_best_tier(count: int, tier_probs: Array, unlocked_tier: int) -> int:
	# Given count forges, what's the likely best tier we'd see?
	# Use probability to estimate
	for tier in range(unlocked_tier, -1, -1):
		var expected_count = tier_probs[tier] * count
		if expected_count >= 1.0:
			return tier
		# Even if expected < 1, there's still a chance
		if randf() < expected_count:
			return tier
	return 0


func _roll_tier() -> int:
	var luck_bonus = game_state.ascension_upgrades.get("soul_luck", 0) * 0.05
	return TierData.roll_tier(game_state.unlocked_tier, luck_bonus)


func _calculate_forge_value(weapon_id: String, tier: int) -> float:
	var base_value = WeaponData.get_base_value(weapon_id)
	var weapon_mult = game_state.weapon_multipliers.get(weapon_id, 1.0)
	var tier_mult = TierData.get_tier_multiplier(tier)
	var click_power = game_state.click_power
	
	# Add weapon mastery bonus
	var mastery_bonus = 1.0 + game_state.get_weapon_mastery_bonus(weapon_id)
	
	# Add streak bonus
	var streak_bonus = 1.0 + game_state.get_streak_bonus()
	
	return base_value * weapon_mult * tier_mult * click_power * mastery_bonus * streak_bonus


func _check_tier_unlocks() -> void:
	var new_tier = TierData.get_max_tier_for_forged(game_state.total_items_forged)
	if new_tier > game_state.unlocked_tier:
		game_state.unlocked_tier = new_tier


func get_weapon_value(weapon_id: String) -> float:
	var base = WeaponData.get_base_value(weapon_id)
	var weapon_mult = game_state.weapon_multipliers.get(weapon_id, 1.0)
	var mastery_bonus = 1.0 + game_state.get_weapon_mastery_bonus(weapon_id)
	var streak_bonus = 1.0 + game_state.get_streak_bonus()
	return base * weapon_mult * game_state.click_power * mastery_bonus * streak_bonus


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
