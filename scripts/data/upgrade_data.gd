class_name UpgradeData
extends RefCounted
## Static upgrade definitions

# Cost scaling
const COST_MULTIPLIER: float = 2.5
const DIMINISHING_RETURN_FACTOR: float = 0.85

# Effect type colors for UI
const EFFECT_TYPE_COLORS: Dictionary = {
	"click_power": Color(1.0, 0.53, 0.27),      # Orange
	"passive_income": Color(0.4, 0.85, 0.4),    # Green
	"auto_forge": Color(0.4, 0.8, 0.9),         # Cyan
	"combo": Color(0.75, 0.5, 0.9),             # Purple
	"multiplier": Color(1.0, 0.85, 0.3)         # Gold
}

const EFFECT_TYPE_LABELS: Dictionary = {
	"click_power": "Click",
	"passive_income": "Passive",
	"auto_forge": "Auto",
	"combo": "Combo",
	"multiplier": "x ALL"
}

const UPGRADES: Dictionary = {
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
		"base_effect": 5.0,
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

const SOUL_UPGRADES: Dictionary = {
	"soul_power": {"name": "Soul Power", "desc": "+10% Click Power", "base_cost": 1},
	"soul_income": {"name": "Soul Income", "desc": "+10% Passive Income", "base_cost": 1},
	"soul_luck": {"name": "Soul Luck", "desc": "+5% Better Items", "base_cost": 2},
	"soul_forge": {"name": "Soul Forge", "desc": "+10% Auto-Forge Speed", "base_cost": 2}
}


static func get_upgrade(upgrade_id: String) -> Dictionary:
	return UPGRADES.get(upgrade_id, {})


static func get_upgrade_ids() -> Array:
	return UPGRADES.keys()


static func get_soul_upgrade(upgrade_id: String) -> Dictionary:
	return SOUL_UPGRADES.get(upgrade_id, {})


static func get_soul_upgrade_ids() -> Array:
	return SOUL_UPGRADES.keys()


static func get_effect_color(effect_type: String) -> Color:
	return EFFECT_TYPE_COLORS.get(effect_type, Color.WHITE)


static func get_effect_label(effect_type: String) -> String:
	return EFFECT_TYPE_LABELS.get(effect_type, "")


static func calculate_cost(upgrade_id: String, current_level: int) -> float:
	var data = UPGRADES.get(upgrade_id, {})
	var base_cost = data.get("base_cost", 100.0)
	return base_cost * pow(COST_MULTIPLIER, current_level)


static func calculate_effect(upgrade_id: String, current_level: int) -> float:
	var data = UPGRADES.get(upgrade_id, {})
	var base_effect = data.get("base_effect", 1.0)
	return base_effect * pow(DIMINISHING_RETURN_FACTOR, current_level)


static func is_maxed(upgrade_id: String, current_level: int) -> bool:
	var data = UPGRADES.get(upgrade_id, {})
	var max_level = data.get("max_level", -1)
	if max_level < 0:
		return false
	return current_level >= max_level
