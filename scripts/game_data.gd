extends Node
class_name GameData

signal gold_changed(new_amount: float)
signal ascension_available()
signal ascended(new_souls: int)
signal achievement_unlocked(achievement_id: String)

# Currency
var gold: float = 0.0
var total_gold_earned: float = 0.0
var highest_gold_ever: float = 0.0

# Ascension System
var ancient_souls: int = 0
var total_ascensions: int = 0
var lifetime_gold: float = 0.0

# Forge stats
var forge_level: int = 1
var click_power: float = 1.0
var passive_income: float = 0.0
var auto_forge_rate: float = 0.0  # Forges per second from auto-forge upgrade

# Currently selected weapon
var selected_weapon: String = "sword"

# Items forged counts per weapon
var items_forged: Dictionary = {
	"sword": 0,
	"dagger": 0,
	"axe": 0,
	"bow": 0,
	"spear": 0,
	"mace": 0,
	"staff": 0
}
var total_items_forged: int = 0

# Current item tier
var unlocked_tier: int = 0

# Weapon multipliers (from soul upgrades)
var weapon_multipliers: Dictionary = {
	"sword": 1.0,
	"dagger": 1.0,
	"axe": 1.0,
	"bow": 1.0,
	"spear": 1.0,
	"mace": 1.0,
	"staff": 1.0
}

# Weapon upgrade levels (purchased with souls)
var weapon_upgrade_levels: Dictionary = {
	"sword": 0,
	"dagger": 0,
	"axe": 0,
	"bow": 0,
	"spear": 0,
	"mace": 0,
	"staff": 0
}

# Upgrades purchased
var upgrades: Dictionary = {}

# Which upgrades have been discovered (seen by player)
var discovered_upgrades: Array = []

# Weapon unlock requirements (ascension count needed)
const WEAPON_UNLOCK_ASCENSIONS: Dictionary = {
	"sword": 0,   # Always unlocked
	"dagger": 1,  # 1st ascension
	"axe": 2,     # 2nd ascension
	"bow": 3,     # 3rd ascension
	"spear": 5,   # 5th ascension
	"mace": 7,    # 7th ascension
	"staff": 10   # 10th ascension
}

# Cost scaling - aggressive!
const UPGRADE_COST_MULTIPLIER: float = 2.5
const DIMINISHING_RETURN_FACTOR: float = 0.85  # Each level gives 85% of previous benefit

# Upgrade definitions - simplified, general only
const UPGRADE_DATA: Dictionary = {
	# === GENERAL UPGRADES ===
	"better_anvil": {
		"name": "Better Anvil", 
		"desc": "+2 Click Power (diminishing)", 
		"base_cost": 15.0, 
		"icon": "W_Mace001.png",
		"category": "general",
		"visibility": 0.3,
		"base_effect": 2.0,
		"effect_type": "click_power"
	},
	"apprentice": {
		"name": "Apprentice", 
		"desc": "+0.5 Gold/sec (diminishing)", 
		"base_cost": 100.0, 
		"icon": "C_Elm01.png",
		"category": "general",
		"visibility": 0.4,
		"base_effect": 0.5,
		"effect_type": "passive_income"
	},
	"auto_forge": {
		"name": "Auto-Forge",
		"desc": "+1 forge/sec (diminishing)",
		"base_cost": 250.0,
		"icon": "E_Metal03.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 1.0,
		"effect_type": "auto_forge"
	},
	"master_smith": {
		"name": "Master Smith", 
		"desc": "+5 Click, +1/sec (diminishing)", 
		"base_cost": 500.0, 
		"icon": "A_Armor04.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 5.0,  # Click power
		"effect_type": "combo"
	},
	"enchanted_forge": {
		"name": "Enchanted Forge", 
		"desc": "x1.5 All Income (one-time)", 
		"base_cost": 2500.0, 
		"icon": "S_Fire01.png",
		"category": "general",
		"visibility": 0.5,
		"max_level": 1,
		"effect_type": "multiplier"
	},
	"golden_hammer": {
		"name": "Golden Hammer", 
		"desc": "+10 Click Power (diminishing)", 
		"base_cost": 5000.0, 
		"icon": "W_Mace007.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 10.0,
		"effect_type": "click_power"
	},
	"forge_masters": {
		"name": "Forge Masters",
		"desc": "+2 forges/sec (diminishing)",
		"base_cost": 8000.0,
		"icon": "A_Armor04.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 2.0,
		"effect_type": "auto_forge"
	},
	"mithril_tools": {
		"name": "Mithril Tools", 
		"desc": "+5/sec Passive (diminishing)", 
		"base_cost": 20000.0, 
		"icon": "E_Metal03.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 5.0,
		"effect_type": "passive_income"
	},
	"dragon_bellows": {
		"name": "Dragon Bellows", 
		"desc": "x2 All Income (one-time)", 
		"base_cost": 100000.0, 
		"icon": "S_Fire07.png",
		"category": "general",
		"visibility": 0.5,
		"max_level": 1,
		"effect_type": "multiplier"
	},
	"time_warp": {
		"name": "Time Warp", 
		"desc": "x3 Everything! (one-time)", 
		"base_cost": 500000.0, 
		"icon": "I_Clock.png",
		"category": "general",
		"visibility": 0.5,
		"max_level": 1,
		"effect_type": "multiplier"
	}
}

const ASCENSION_UPGRADE_DATA: Dictionary = {
	"soul_power": {"name": "Soul Power", "desc": "+10% Click Power", "base_cost": 1},
	"soul_income": {"name": "Soul Income", "desc": "+10% Passive Income", "base_cost": 1},
	"soul_luck": {"name": "Soul Luck", "desc": "+5% Better Items", "base_cost": 2},
	"soul_forge": {"name": "Soul Forge", "desc": "+10% Auto-Forge Speed", "base_cost": 2}
}

# Weapon upgrade costs (souls) - increases per level
const WEAPON_UPGRADE_BASE_COST: int = 3
const WEAPON_UPGRADE_COST_MULTIPLIER: float = 1.5

# Achievement definitions
const ACHIEVEMENTS: Dictionary = {
	# Forging milestones
	"first_forge": {"name": "First Steps", "desc": "Forge your first weapon", "icon": "W_Sword001.png", "reward": 0},
	"forge_10": {"name": "Apprentice Smith", "desc": "Forge 10 weapons", "icon": "W_Sword005.png", "reward": 5},
	"forge_100": {"name": "Journeyman", "desc": "Forge 100 weapons", "icon": "W_Sword010.png", "reward": 25},
	"forge_1000": {"name": "Master Smith", "desc": "Forge 1,000 weapons", "icon": "W_Sword015.png", "reward": 100},
	"forge_10000": {"name": "Legendary Forger", "desc": "Forge 10,000 weapons", "icon": "W_Sword021.png", "reward": 500},
	
	# Gold milestones
	"gold_100": {"name": "Pocket Change", "desc": "Earn 100 gold", "icon": "I_GoldCoin.png", "reward": 0},
	"gold_1k": {"name": "Small Fortune", "desc": "Earn 1,000 gold", "icon": "I_GoldCoin.png", "reward": 10},
	"gold_10k": {"name": "Wealthy", "desc": "Earn 10,000 gold", "icon": "I_GoldCoin.png", "reward": 50},
	"gold_100k": {"name": "Rich", "desc": "Earn 100,000 gold", "icon": "I_GoldCoin.png", "reward": 200},
	"gold_1m": {"name": "Millionaire", "desc": "Earn 1,000,000 gold", "icon": "I_GoldCoin.png", "reward": 1000},
	
	# Tier achievements
	"tier_uncommon": {"name": "Quality Work", "desc": "Unlock Uncommon tier", "icon": "S_Buff01.png", "reward": 10},
	"tier_rare": {"name": "Rare Find", "desc": "Unlock Rare tier", "icon": "S_Buff05.png", "reward": 50},
	"tier_epic": {"name": "Epic Craft", "desc": "Unlock Epic tier", "icon": "S_Buff08.png", "reward": 200},
	"tier_legendary": {"name": "Legendary!", "desc": "Unlock Legendary tier", "icon": "S_Buff10.png", "reward": 1000},
	
	# Ascension
	"first_ascend": {"name": "Transcendence", "desc": "Ascend for the first time", "icon": "S_Light01.png", "reward": 0},
	"ascend_5": {"name": "Eternal Smith", "desc": "Ascend 5 times", "icon": "S_Light05.png", "reward": 0},
	"ascend_10": {"name": "Immortal Forger", "desc": "Ascend 10 times", "icon": "S_Light10.png", "reward": 0},
	
	# Weapon unlocks
	"unlock_dagger": {"name": "Swift Blade", "desc": "Unlock the Dagger", "icon": "W_Dagger010.png", "reward": 0},
	"unlock_axe": {"name": "Heavy Hitter", "desc": "Unlock the Axe", "icon": "W_Axe007.png", "reward": 0},
	"unlock_bow": {"name": "Ranger's Choice", "desc": "Unlock the Bow", "icon": "W_Bow07.png", "reward": 0},
	"unlock_all": {"name": "Arsenal Complete", "desc": "Unlock all weapons", "icon": "E_Metal03.png", "reward": 0}
}

# Unlocked achievements
var unlocked_achievements: Array = []
var pending_achievement_rewards: float = 0.0

# Offline progress
var last_save_timestamp: float = 0.0
const MAX_OFFLINE_HOURS: float = 8.0
const OFFLINE_EFFICIENCY: float = 0.5

# Ascension upgrades (permanent)
var ascension_upgrades: Dictionary = {
	"soul_power": 0,
	"soul_income": 0,
	"soul_luck": 0,
	"soul_forge": 0
}

const ASCENSION_THRESHOLD: float = 100000.0

# Item tiers with colors
const ITEM_TIERS = [
	{"name": "Common", "color": Color(0.7, 0.7, 0.7), "multiplier": 1.0},
	{"name": "Uncommon", "color": Color(0.3, 0.8, 0.3), "multiplier": 2.0},
	{"name": "Rare", "color": Color(0.3, 0.5, 1.0), "multiplier": 5.0},
	{"name": "Epic", "color": Color(0.7, 0.3, 0.9), "multiplier": 15.0},
	{"name": "Legendary", "color": Color(1.0, 0.6, 0.1), "multiplier": 50.0}
]

# Weapon base values
const WEAPON_BASE_VALUES: Dictionary = {
	"sword": 1.0,
	"dagger": 0.8,
	"axe": 1.2,
	"bow": 1.0,
	"spear": 1.1,
	"mace": 1.3,
	"staff": 1.5
}

func _init() -> void:
	for key in UPGRADE_DATA:
		upgrades[key] = 0

func is_weapon_unlocked(weapon_id: String) -> bool:
	var required_ascensions = WEAPON_UNLOCK_ASCENSIONS.get(weapon_id, 999)
	return total_ascensions >= required_ascensions

func get_unlocked_weapons() -> Array:
	var unlocked = []
	for weapon_id in WEAPON_UNLOCK_ASCENSIONS:
		if is_weapon_unlocked(weapon_id):
			unlocked.append(weapon_id)
	return unlocked

func get_weapon_value(weapon_id: String) -> float:
	var base = WEAPON_BASE_VALUES.get(weapon_id, 1.0)
	var weapon_mult = weapon_multipliers.get(weapon_id, 1.0)
	return base * weapon_mult * click_power

func get_effective_auto_forge_rate() -> float:
	var soul_bonus = 1.0 + (ascension_upgrades.get("soul_forge", 0) * 0.10)
	return auto_forge_rate * soul_bonus

func is_upgrade_visible(upgrade_key: String) -> bool:
	if upgrades.get(upgrade_key, 0) > 0:
		return true
	
	if upgrade_key in discovered_upgrades:
		return true
	
	var data = UPGRADE_DATA.get(upgrade_key, {})
	var base_cost = data.get("base_cost", 100.0)
	var visibility_threshold = data.get("visibility", 0.5)
	
	if highest_gold_ever >= base_cost * visibility_threshold:
		discovered_upgrades.append(upgrade_key)
		return true
	
	return false

func is_upgrade_maxed(upgrade_key: String) -> bool:
	var data = UPGRADE_DATA.get(upgrade_key, {})
	var max_level = data.get("max_level", -1)  # -1 means unlimited
	if max_level < 0:
		return false
	return upgrades.get(upgrade_key, 0) >= max_level

func get_visible_upgrades() -> Array:
	var visible = []
	for key in UPGRADE_DATA:
		if is_upgrade_visible(key) and not is_upgrade_maxed(key):
			visible.append(key)
	return visible

func get_ascension_bonus() -> float:
	var bonus = 1.0
	bonus += ascension_upgrades["soul_power"] * 0.10
	bonus += ascension_upgrades["soul_income"] * 0.10
	bonus += ancient_souls * 0.01
	return bonus

func get_souls_on_ascension() -> int:
	return int(sqrt(total_gold_earned / 10000.0))

func can_ascend() -> bool:
	return total_gold_earned >= ASCENSION_THRESHOLD

func ascend() -> int:
	if not can_ascend():
		return 0
	
	var souls_earned = get_souls_on_ascension()
	ancient_souls += souls_earned
	total_ascensions += 1
	lifetime_gold += total_gold_earned
	
	# Reset progress
	gold = 0.0
	total_gold_earned = 0.0
	click_power = 1.0
	passive_income = 0.0
	auto_forge_rate = 0.0
	unlocked_tier = 0
	
	for key in items_forged:
		items_forged[key] = 0
	total_items_forged = 0
	
	for key in upgrades:
		upgrades[key] = 0
	
	highest_gold_ever = 0.0
	discovered_upgrades.clear()
	
	# Apply ascension bonus to starting click power
	click_power *= get_ascension_bonus()
	
	# Check for weapon unlock achievements
	_check_weapon_unlock_achievements()
	
	ascended.emit(souls_earned)
	return souls_earned

func _check_weapon_unlock_achievements() -> void:
	if is_weapon_unlocked("dagger"):
		_try_unlock("unlock_dagger", true)
	if is_weapon_unlocked("axe"):
		_try_unlock("unlock_axe", true)
	if is_weapon_unlocked("bow"):
		_try_unlock("unlock_bow", true)
	
	# Check if all weapons unlocked
	var all_unlocked = true
	for weapon_id in WEAPON_UNLOCK_ASCENSIONS:
		if not is_weapon_unlocked(weapon_id):
			all_unlocked = false
			break
	if all_unlocked:
		_try_unlock("unlock_all", true)

func purchase_ascension_upgrade(upgrade_name: String) -> bool:
	var data = ASCENSION_UPGRADE_DATA.get(upgrade_name, {})
	var cost = data.get("base_cost", 1) * (ascension_upgrades.get(upgrade_name, 0) + 1)
	
	if ancient_souls >= cost:
		ancient_souls -= cost
		ascension_upgrades[upgrade_name] = ascension_upgrades.get(upgrade_name, 0) + 1
		return true
	return false

func get_weapon_upgrade_cost(weapon_id: String) -> int:
	var level = weapon_upgrade_levels.get(weapon_id, 0)
	return int(WEAPON_UPGRADE_BASE_COST * pow(WEAPON_UPGRADE_COST_MULTIPLIER, level))

func purchase_weapon_upgrade(weapon_id: String) -> bool:
	if not is_weapon_unlocked(weapon_id):
		return false
	
	var cost = get_weapon_upgrade_cost(weapon_id)
	if ancient_souls >= cost:
		ancient_souls -= cost
		weapon_upgrade_levels[weapon_id] = weapon_upgrade_levels.get(weapon_id, 0) + 1
		# Each level gives +25% to weapon multiplier
		weapon_multipliers[weapon_id] = 1.0 + (weapon_upgrade_levels[weapon_id] * 0.25)
		return true
	return false

func get_upgrade_cost(upgrade_name: String) -> float:
	var data = UPGRADE_DATA.get(upgrade_name, {})
	var base_cost = data.get("base_cost", 100.0)
	var level = upgrades.get(upgrade_name, 0)
	return base_cost * pow(UPGRADE_COST_MULTIPLIER, level)

func get_upgrade_effect(upgrade_name: String) -> float:
	var data = UPGRADE_DATA.get(upgrade_name, {})
	var base_effect = data.get("base_effect", 1.0)
	var level = upgrades.get(upgrade_name, 0)
	# Diminishing returns: each level gives 85% of previous
	return base_effect * pow(DIMINISHING_RETURN_FACTOR, level)

func purchase_upgrade(upgrade_name: String) -> bool:
	if is_upgrade_maxed(upgrade_name):
		return false
	
	var cost = get_upgrade_cost(upgrade_name)
	if gold >= cost:
		gold -= cost
		upgrades[upgrade_name] = upgrades.get(upgrade_name, 0) + 1
		_apply_upgrade(upgrade_name)
		gold_changed.emit(gold)
		return true
	return false

func _apply_upgrade(upgrade_name: String) -> void:
	var bonus = get_ascension_bonus()
	var data = UPGRADE_DATA.get(upgrade_name, {})
	var effect = get_upgrade_effect(upgrade_name)
	
	match upgrade_name:
		"better_anvil":
			click_power += effect * bonus
		"apprentice":
			passive_income += effect * bonus
		"auto_forge":
			auto_forge_rate += effect
		"master_smith":
			click_power += effect * bonus
			passive_income += (effect * 0.2) * bonus  # 1/5 of click effect for passive
		"enchanted_forge":
			click_power *= 1.5
			passive_income *= 1.5
			auto_forge_rate *= 1.5
		"golden_hammer":
			click_power += effect * bonus
		"forge_masters":
			auto_forge_rate += effect
		"mithril_tools":
			passive_income += effect * bonus
		"dragon_bellows":
			click_power *= 2.0
			passive_income *= 2.0
			auto_forge_rate *= 2.0
		"time_warp":
			click_power *= 3.0
			passive_income *= 3.0
			auto_forge_rate *= 3.0
	
	_check_tier_unlocks()

func _check_tier_unlocks() -> void:
	if total_items_forged >= 1000 and unlocked_tier < 4:
		unlocked_tier = 4
	elif total_items_forged >= 500 and unlocked_tier < 3:
		unlocked_tier = 3
	elif total_items_forged >= 100 and unlocked_tier < 2:
		unlocked_tier = 2
	elif total_items_forged >= 25 and unlocked_tier < 1:
		unlocked_tier = 1

func get_random_tier() -> int:
	var luck_bonus = ascension_upgrades.get("soul_luck", 0) * 0.05
	var roll = randf() + luck_bonus
	
	if roll > 0.99 and unlocked_tier >= 4:
		return 4
	elif roll > 0.95 and unlocked_tier >= 3:
		return 3
	elif roll > 0.85 and unlocked_tier >= 2:
		return 2
	elif roll > 0.65 and unlocked_tier >= 1:
		return 1
	else:
		return 0

func add_gold(amount: float) -> void:
	var bonus = get_ascension_bonus()
	var final_amount = amount * bonus
	gold += final_amount
	total_gold_earned += final_amount
	
	if gold > highest_gold_ever:
		highest_gold_ever = gold
	
	gold_changed.emit(gold)
	
	if can_ascend():
		ascension_available.emit()
	
	check_achievements()

func select_weapon(weapon_id: String) -> void:
	if is_weapon_unlocked(weapon_id):
		selected_weapon = weapon_id

func check_achievements() -> void:
	# Forging milestones
	_try_unlock("first_forge", total_items_forged >= 1)
	_try_unlock("forge_10", total_items_forged >= 10)
	_try_unlock("forge_100", total_items_forged >= 100)
	_try_unlock("forge_1000", total_items_forged >= 1000)
	_try_unlock("forge_10000", total_items_forged >= 10000)
	
	# Gold milestones
	var total_ever = lifetime_gold + total_gold_earned
	_try_unlock("gold_100", total_ever >= 100)
	_try_unlock("gold_1k", total_ever >= 1000)
	_try_unlock("gold_10k", total_ever >= 10000)
	_try_unlock("gold_100k", total_ever >= 100000)
	_try_unlock("gold_1m", total_ever >= 1000000)
	
	# Tier achievements
	_try_unlock("tier_uncommon", unlocked_tier >= 1)
	_try_unlock("tier_rare", unlocked_tier >= 2)
	_try_unlock("tier_epic", unlocked_tier >= 3)
	_try_unlock("tier_legendary", unlocked_tier >= 4)
	
	# Ascension
	_try_unlock("first_ascend", total_ascensions >= 1)
	_try_unlock("ascend_5", total_ascensions >= 5)
	_try_unlock("ascend_10", total_ascensions >= 10)
	
	# Weapon unlocks are checked in ascend()

func _try_unlock(achievement_id: String, condition: bool) -> void:
	if condition and achievement_id not in unlocked_achievements:
		unlocked_achievements.append(achievement_id)
		var data = ACHIEVEMENTS.get(achievement_id, {})
		var reward = data.get("reward", 0)
		if reward > 0:
			pending_achievement_rewards += reward
		achievement_unlocked.emit(achievement_id)

func claim_achievement_rewards() -> float:
	var rewards = pending_achievement_rewards
	if rewards > 0:
		gold += rewards
		gold_changed.emit(gold)
		pending_achievement_rewards = 0.0
	return rewards

func get_achievement_progress() -> Dictionary:
	var total = ACHIEVEMENTS.size()
	# Only count valid achievements (in case old save has removed achievements)
	var valid_unlocked = 0
	for achievement_id in unlocked_achievements:
		if achievement_id in ACHIEVEMENTS:
			valid_unlocked += 1
	return {"unlocked": valid_unlocked, "total": total, "percent": float(valid_unlocked) / float(total) * 100.0}

func calculate_offline_progress() -> Dictionary:
	if last_save_timestamp <= 0 or (passive_income <= 0 and auto_forge_rate <= 0):
		return {"gold": 0.0, "seconds": 0.0}
	
	var current_time = Time.get_unix_time_from_system()
	var elapsed_seconds = current_time - last_save_timestamp
	
	var max_seconds = MAX_OFFLINE_HOURS * 3600.0
	elapsed_seconds = minf(elapsed_seconds, max_seconds)
	
	if elapsed_seconds < 60:
		return {"gold": 0.0, "seconds": 0.0}
	
	# Calculate offline gold from passive income
	var offline_gold = passive_income * elapsed_seconds * OFFLINE_EFFICIENCY * get_ascension_bonus()
	
	# Add gold from auto-forge (at reduced efficiency)
	var auto_forge_gold = get_effective_auto_forge_rate() * elapsed_seconds * OFFLINE_EFFICIENCY * click_power * get_ascension_bonus()
	offline_gold += auto_forge_gold
	
	return {"gold": offline_gold, "seconds": elapsed_seconds}

func apply_offline_progress(offline_gold: float) -> void:
	if offline_gold > 0:
		gold += offline_gold
		total_gold_earned += offline_gold
		if gold > highest_gold_ever:
			highest_gold_ever = gold
		gold_changed.emit(gold)
		check_achievements()

func reset_all_progress() -> void:
	# Reset everything to default
	gold = 0.0
	total_gold_earned = 0.0
	highest_gold_ever = 0.0
	lifetime_gold = 0.0
	ancient_souls = 0
	total_ascensions = 0
	forge_level = 1
	click_power = 1.0
	passive_income = 0.0
	auto_forge_rate = 0.0
	selected_weapon = "sword"
	unlocked_tier = 0
	
	for key in items_forged:
		items_forged[key] = 0
	total_items_forged = 0
	
	for key in weapon_multipliers:
		weapon_multipliers[key] = 1.0
	
	for key in weapon_upgrade_levels:
		weapon_upgrade_levels[key] = 0
	
	for key in upgrades:
		upgrades[key] = 0
	
	discovered_upgrades.clear()
	
	for key in ascension_upgrades:
		ascension_upgrades[key] = 0
	
	unlocked_achievements.clear()
	pending_achievement_rewards = 0.0
	last_save_timestamp = 0.0
	
	# Delete save file
	if FileAccess.file_exists("user://savegame.save"):
		DirAccess.remove_absolute("user://savegame.save")
	
	gold_changed.emit(gold)

func format_number(num: float) -> String:
	if num >= 100000000000:
		var exponent = int(log(num) / log(10))
		var mantissa = num / pow(10, exponent)
		return "%.2fe%d" % [mantissa, exponent]
	elif num >= 1000000000:
		return "%.2fB" % (num / 1000000000.0)
	elif num >= 1000000:
		return "%.2fM" % (num / 1000000.0)
	elif num >= 1000:
		return "%.1fK" % (num / 1000.0)
	else:
		return "%.0f" % num

func get_formatted_gold() -> String:
	return format_number(gold)

func save_game() -> void:
	last_save_timestamp = Time.get_unix_time_from_system()
	var save_data = {
		"gold": gold,
		"total_gold_earned": total_gold_earned,
		"highest_gold_ever": highest_gold_ever,
		"lifetime_gold": lifetime_gold,
		"ancient_souls": ancient_souls,
		"total_ascensions": total_ascensions,
		"forge_level": forge_level,
		"click_power": click_power,
		"passive_income": passive_income,
		"auto_forge_rate": auto_forge_rate,
		"selected_weapon": selected_weapon,
		"weapon_multipliers": weapon_multipliers,
		"weapon_upgrade_levels": weapon_upgrade_levels,
		"items_forged": items_forged,
		"total_items_forged": total_items_forged,
		"unlocked_tier": unlocked_tier,
		"upgrades": upgrades,
		"discovered_upgrades": discovered_upgrades,
		"ascension_upgrades": ascension_upgrades,
		"unlocked_achievements": unlocked_achievements,
		"pending_achievement_rewards": pending_achievement_rewards,
		"last_save_timestamp": last_save_timestamp
	}
	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))

func load_game() -> void:
	for key in UPGRADE_DATA:
		if not upgrades.has(key):
			upgrades[key] = 0
	
	if FileAccess.file_exists("user://savegame.save"):
		var file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			var save_data = json.get_data()
			gold = save_data.get("gold", 0.0)
			total_gold_earned = save_data.get("total_gold_earned", 0.0)
			highest_gold_ever = save_data.get("highest_gold_ever", 0.0)
			lifetime_gold = save_data.get("lifetime_gold", 0.0)
			ancient_souls = save_data.get("ancient_souls", 0)
			total_ascensions = save_data.get("total_ascensions", 0)
			forge_level = save_data.get("forge_level", 1)
			click_power = save_data.get("click_power", 1.0)
			passive_income = save_data.get("passive_income", 0.0)
			auto_forge_rate = save_data.get("auto_forge_rate", 0.0)
			selected_weapon = save_data.get("selected_weapon", "sword")
			total_items_forged = save_data.get("total_items_forged", 0)
			unlocked_tier = save_data.get("unlocked_tier", 0)
			discovered_upgrades = save_data.get("discovered_upgrades", [])
			
			var saved_multipliers = save_data.get("weapon_multipliers", {})
			for key in weapon_multipliers:
				weapon_multipliers[key] = saved_multipliers.get(key, 1.0)
			
			var saved_weapon_levels = save_data.get("weapon_upgrade_levels", {})
			for key in weapon_upgrade_levels:
				weapon_upgrade_levels[key] = saved_weapon_levels.get(key, 0)
			
			var saved_items = save_data.get("items_forged", {})
			for key in items_forged:
				items_forged[key] = saved_items.get(key, 0)
			
			var saved_upgrades = save_data.get("upgrades", {})
			for key in upgrades:
				upgrades[key] = saved_upgrades.get(key, 0)
			
			var saved_asc = save_data.get("ascension_upgrades", {})
			for key in ascension_upgrades:
				ascension_upgrades[key] = saved_asc.get(key, 0)
			
			unlocked_achievements = save_data.get("unlocked_achievements", [])
			pending_achievement_rewards = save_data.get("pending_achievement_rewards", 0.0)
			last_save_timestamp = save_data.get("last_save_timestamp", 0.0)
