class_name TierData
extends RefCounted
## Item tier definitions and utilities

const TIERS: Array = [
	{"name": "Common", "color": Color(0.7, 0.7, 0.7), "multiplier": 1.0},
	{"name": "Uncommon", "color": Color(0.3, 0.8, 0.3), "multiplier": 2.0},
	{"name": "Rare", "color": Color(0.3, 0.5, 1.0), "multiplier": 5.0},
	{"name": "Epic", "color": Color(0.7, 0.3, 0.9), "multiplier": 15.0},
	{"name": "Legendary", "color": Color(1.0, 0.6, 0.1), "multiplier": 50.0}
]

# Tier unlock thresholds (items forged)
const UNLOCK_THRESHOLDS: Array = [0, 25, 100, 500, 1000]

# Drop rates (base chance to NOT get this tier, if unlocked)
const DROP_THRESHOLDS: Array = [0.0, 0.65, 0.85, 0.95, 0.99]


static func get_tier(tier_index: int) -> Dictionary:
	if tier_index >= 0 and tier_index < TIERS.size():
		return TIERS[tier_index]
	return TIERS[0]


static func get_tier_name(tier_index: int) -> String:
	return get_tier(tier_index).get("name", "Common")


static func get_tier_color(tier_index: int) -> Color:
	return get_tier(tier_index).get("color", Color.WHITE)


static func get_tier_multiplier(tier_index: int) -> float:
	return get_tier(tier_index).get("multiplier", 1.0)


static func get_max_tier_for_forged(total_forged: int) -> int:
	var max_tier = 0
	for i in range(UNLOCK_THRESHOLDS.size()):
		if total_forged >= UNLOCK_THRESHOLDS[i]:
			max_tier = i
	return max_tier


static func roll_tier(unlocked_tier: int, luck_bonus: float = 0.0) -> int:
	var roll = randf() + luck_bonus
	
	if roll > DROP_THRESHOLDS[4] and unlocked_tier >= 4:
		return 4
	elif roll > DROP_THRESHOLDS[3] and unlocked_tier >= 3:
		return 3
	elif roll > DROP_THRESHOLDS[2] and unlocked_tier >= 2:
		return 2
	elif roll > DROP_THRESHOLDS[1] and unlocked_tier >= 1:
		return 1
	else:
		return 0
