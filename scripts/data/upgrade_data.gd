class_name UpgradeData
extends RefCounted
## Static upgrade definitions

# Cost scaling
const COST_MULTIPLIER: float = 2.5
const DIMINISHING_RETURN_FACTOR: float = 0.85

# Super-scaling for expensive upgrades (makes late-game grindier)
# Upgrades above these thresholds scale faster
const SUPER_SCALE_THRESHOLD_1: float = 1000000.0    # 1M - cost multiplier becomes 3.0
const SUPER_SCALE_THRESHOLD_2: float = 1000000000.0 # 1B - cost multiplier becomes 4.0
const SUPER_SCALE_THRESHOLD_3: float = 1000000000000.0 # 1T - cost multiplier becomes 5.0

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
	# === EARLY GAME UPGRADES ===
	"better_anvil": {
		"name": "Better Anvil", 
		"desc": "+2 Click Power", 
		"lore": "A well-worn anvil passed down through generations of smiths.",
		"base_cost": 15.0, 
		"icon": "W_Mace001.png",
		"category": "general",
		"visibility": 0.3,
		"base_effect": 2.0,
		"effect_type": "click_power"
	},
	"apprentice": {
		"name": "Apprentice", 
		"desc": "+0.5 Gold/sec", 
		"lore": "A young helper eager to learn the ways of the forge.",
		"base_cost": 100.0, 
		"icon": "C_Elm01.png",
		"category": "general",
		"visibility": 0.4,
		"base_effect": 0.5,
		"effect_type": "passive_income"
	},
	"auto_forge": {
		"name": "Auto-Forge",
		"desc": "+1 forge/sec",
		"lore": "Simple mechanisms that keep the bellows pumping while you rest.",
		"base_cost": 250.0,
		"icon": "E_Metal03.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 1.0,
		"effect_type": "auto_forge"
	},
	"swift_hammer": {
		"name": "Swift Hammer",
		"desc": "+0.5 forge/sec",
		"lore": "Lighter than it looks, this hammer moves like an extension of your arm.",
		"base_cost": 400.0,
		"icon": "W_Mace002.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 0.5,
		"effect_type": "auto_forge"
	},
	"master_smith": {
		"name": "Master Smith", 
		"desc": "+5 Click, +1/sec", 
		"lore": "Years of practice have honed your technique to near perfection.",
		"base_cost": 500.0, 
		"icon": "A_Armor04.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 5.0,
		"effect_type": "combo"
	},
	"forge_bellows": {
		"name": "Forge Bellows",
		"desc": "+1.5 forge/sec",
		"lore": "Massive leather bellows that roar with every compression.",
		"base_cost": 1500.0,
		"icon": "E_Metal01.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 1.5,
		"effect_type": "auto_forge"
	},
	
	# === ONE-TIME MULTIPLIERS (Early) ===
	"enchanted_forge": {
		"name": "Enchanted Forge", 
		"desc": "x1.5 All Income", 
		"lore": "Ancient runes etched into the forge stones pulse with otherworldly light.",
		"base_cost": 5000.0, 
		"icon": "S_Fire01.png",
		"category": "general",
		"visibility": 0.5,
		"max_level": 1,
		"effect_type": "multiplier"
	},
	
	# === MID GAME UPGRADES ===
	"golden_hammer": {
		"name": "Golden Hammer", 
		"desc": "+10 Click Power", 
		"lore": "Gilded and balanced to perfection, a symbol of mastery.",
		"base_cost": 10000.0, 
		"icon": "W_Mace007.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 10.0,
		"effect_type": "click_power"
	},
	"forge_masters": {
		"name": "Forge Masters",
		"desc": "+2 forges/sec",
		"lore": "Veteran smiths who remember the old ways before the kingdoms fell.",
		"base_cost": 25000.0,
		"icon": "A_Armor04.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 2.0,
		"effect_type": "auto_forge"
	},
	"mechanical_arm": {
		"name": "Mechanical Arm",
		"desc": "+3 forges/sec",
		"lore": "Dwarven engineering at its finest—tireless and precise.",
		"base_cost": 75000.0,
		"icon": "E_Metal02.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 3.0,
		"effect_type": "auto_forge"
	},
	"mithril_tools": {
		"name": "Mithril Tools", 
		"desc": "+5/sec Passive", 
		"lore": "Tools forged from starfall metal, light as feathers yet strong as steel.",
		"base_cost": 150000.0, 
		"icon": "E_Metal03.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 5.0,
		"effect_type": "passive_income"
	},
	"golem_assistant": {
		"name": "Golem Assistant",
		"desc": "+5 forges/sec",
		"lore": "A construct of stone and spirit, bound to serve the forge eternally.",
		"base_cost": 500000.0,
		"icon": "C_Elm02.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 5.0,
		"effect_type": "auto_forge"
	},
	
	# === ONE-TIME MULTIPLIERS (Mid) ===
	"dragon_bellows": {
		"name": "Dragon Bellows", 
		"desc": "x2 All Income", 
		"lore": "Crafted from the lungs of a fallen wyrm, they breathe eternal fire.",
		"base_cost": 1000000.0, 
		"icon": "S_Fire07.png",
		"category": "general",
		"visibility": 0.5,
		"max_level": 1,
		"effect_type": "multiplier"
	},
	"runic_enchantment": {
		"name": "Runic Enchantment",
		"desc": "x1.5 All Income",
		"lore": "Words of power carved in the language of the First Smith.",
		"base_cost": 2500000.0,
		"icon": "S_Magic01.png",
		"category": "general",
		"visibility": 0.5,
		"max_level": 1,
		"effect_type": "multiplier"
	},
	
	# === LATE GAME UPGRADES ===
	"dwarven_machinery": {
		"name": "Dwarven Machinery",
		"desc": "+10 forges/sec",
		"lore": "Gears within gears, powered by geothermal vents deep below.",
		"base_cost": 5000000.0,
		"icon": "E_Metal04.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 10.0,
		"effect_type": "auto_forge"
	},
	"time_warp": {
		"name": "Time Warp", 
		"desc": "x3 Everything!", 
		"lore": "The boundary between moments grows thin around your forge.",
		"base_cost": 10000000.0, 
		"icon": "I_Clock.png",
		"category": "general",
		"visibility": 0.5,
		"max_level": 1,
		"effect_type": "multiplier"
	},
	"elemental_forge": {
		"name": "Elemental Forge",
		"desc": "+20 forges/sec",
		"lore": "Fire, water, earth, and air converge at your command.",
		"base_cost": 25000000.0,
		"icon": "S_Fire03.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 20.0,
		"effect_type": "auto_forge"
	},
	"arcane_anvil": {
		"name": "Arcane Anvil",
		"desc": "x2 All Income",
		"lore": "This anvil exists in multiple planes simultaneously.",
		"base_cost": 50000000.0,
		"icon": "W_Mace010.png",
		"category": "general",
		"visibility": 0.5,
		"max_level": 1,
		"effect_type": "multiplier"
	},
	
	# === POST-ASCENSION UPGRADES (Expect 1+ ascensions) ===
	"soul_infused_hammer": {
		"name": "Soul-Infused Hammer",
		"desc": "+50 Click Power",
		"lore": "The spirits of master smiths guide every strike.",
		"base_cost": 250000000.0,
		"icon": "W_Mace011.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 50.0,
		"effect_type": "click_power"
	},
	"spectral_workers": {
		"name": "Spectral Workers",
		"desc": "+50 forges/sec",
		"lore": "Ghostly smiths who toil without rest, their hammers silent but effective.",
		"base_cost": 1000000000.0,
		"icon": "C_Elm03.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 50.0,
		"effect_type": "auto_forge"
	},
	"ancient_blessing": {
		"name": "Ancient Blessing",
		"desc": "x5 All Income",
		"lore": "Valdris himself reaches across time to bless your work.",
		"base_cost": 5000000000.0,
		"icon": "S_Holy01.png",
		"category": "general",
		"visibility": 0.5,
		"max_level": 1,
		"effect_type": "multiplier"
	},
	"titan_forge": {
		"name": "Titan Forge",
		"desc": "+100 forges/sec",
		"lore": "Built by giants in an age before memory, now yours to command.",
		"base_cost": 25000000000.0,
		"icon": "S_Fire04.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 100.0,
		"effect_type": "auto_forge"
	},
	"celestial_smithy": {
		"name": "Celestial Smithy",
		"desc": "x10 All Income",
		"lore": "Your forge burns with the light of distant stars.",
		"base_cost": 100000000000.0,
		"icon": "S_Light01.png",
		"category": "general",
		"visibility": 0.5,
		"max_level": 1,
		"effect_type": "multiplier"
	},
	
	# === DEEP POST-ASCENSION (Expect 5+ ascensions) ===
	"void_automation": {
		"name": "Void Automation",
		"desc": "+500 forges/sec",
		"lore": "Machines from beyond reality, operating on principles no mortal understands.",
		"base_cost": 1000000000000.0,
		"icon": "S_Dark01.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 500.0,
		"effect_type": "auto_forge"
	},
	"divine_anvil": {
		"name": "Divine Anvil",
		"desc": "x25 All Income",
		"lore": "The gods themselves once shaped fate upon this anvil.",
		"base_cost": 10000000000000.0,
		"icon": "S_Holy02.png",
		"category": "general",
		"visibility": 0.5,
		"max_level": 1,
		"effect_type": "multiplier"
	},
	"eternal_flames": {
		"name": "Eternal Flames",
		"desc": "+1000 forges/sec",
		"lore": "Fire stolen from the heart of a dying sun, it will never fade.",
		"base_cost": 100000000000000.0,
		"icon": "S_Fire05.png",
		"category": "general",
		"visibility": 0.5,
		"base_effect": 1000.0,
		"effect_type": "auto_forge"
	},
	"cosmic_forge": {
		"name": "Cosmic Forge",
		"desc": "x100 All Income",
		"lore": "At the edge of existence, you forge weapons that can unmake reality.",
		"base_cost": 1000000000000000.0,
		"icon": "S_Light02.png",
		"category": "general",
		"visibility": 0.5,
		"max_level": 1,
		"effect_type": "multiplier"
	}
}

const SOUL_UPGRADES: Dictionary = {
	"soul_power": {"name": "Soul Power", "desc": "+10% Click Power", "base_cost": 5},
	"soul_income": {"name": "Soul Income", "desc": "+10% Passive Income", "base_cost": 5},
	"soul_luck": {"name": "Soul Luck", "desc": "+5% Better Items", "base_cost": 10},
	"soul_forge": {"name": "Soul Forge", "desc": "+10% Auto-Forge Speed", "base_cost": 8}
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
	
	# Determine cost multiplier based on base cost tier
	var mult = COST_MULTIPLIER
	if base_cost >= SUPER_SCALE_THRESHOLD_3:
		mult = 5.0
	elif base_cost >= SUPER_SCALE_THRESHOLD_2:
		mult = 4.0
	elif base_cost >= SUPER_SCALE_THRESHOLD_1:
		mult = 3.0
	
	return base_cost * pow(mult, current_level)


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
