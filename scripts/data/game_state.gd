class_name GameState
extends Node
## Pure data container for game state - no logic, just data
## All game logic is in managers

const UpgradeData = preload("res://scripts/data/upgrade_data.gd")

# Currency
var gold: float = 0.0
var total_gold_earned: float = 0.0
var highest_gold_ever: float = 0.0
var lifetime_gold: float = 0.0

# Ascension System
var ancient_souls: int = 0
var total_ascensions: int = 0
var last_ascension_souls: int = 0  # Souls earned on last ascension

# Forge stats
var forge_level: int = 1
var click_power: float = 1.0
var passive_income: float = 0.0
var auto_forge_rate: float = 0.0

# Selected weapon
var selected_weapon: String = "sword"

# Items forged counts per weapon
var items_forged: Dictionary = {
	"sword": 0, "dagger": 0, "axe": 0, "bow": 0,
	"spear": 0, "mace": 0, "staff": 0
}
var total_items_forged: int = 0

# Current item tier
var unlocked_tier: int = 0

# Weapon multipliers (from soul upgrades)
var weapon_multipliers: Dictionary = {
	"sword": 1.0, "dagger": 1.0, "axe": 1.0, "bow": 1.0,
	"spear": 1.0, "mace": 1.0, "staff": 1.0
}

# Weapon upgrade levels
var weapon_upgrade_levels: Dictionary = {
	"sword": 0, "dagger": 0, "axe": 0, "bow": 0,
	"spear": 0, "mace": 0, "staff": 0
}

# Upgrades purchased
var upgrades: Dictionary = {}

# Discovered upgrades
var discovered_upgrades: Array = []

# Ascension upgrades
var ascension_upgrades: Dictionary = {
	"soul_power": 0, "soul_income": 0, "soul_luck": 0, "soul_forge": 0
}

# Multiplier tracking for diminishing returns
var total_multipliers_purchased: int = 0

# Automation settings
var auto_buy_enabled: bool = false
var auto_ascend_enabled: bool = false
var auto_ascend_threshold: float = 2.0  # Multiplier of minimum (e.g., 2.0 = ascend at 2x min souls)

# Endgame
var game_completed: bool = false

# Achievements
var unlocked_achievements: Array = []
var pending_achievement_rewards: float = 0.0

# Offline progress
var last_save_timestamp: float = 0.0

# Shown milestones (to prevent repeat popups)
var shown_milestones: Dictionary = {}

# Settings
var ui_scale: float = 1.0  # 0.8 to 1.5


func _init() -> void:
	pass


func initialize_upgrades() -> void:
	# Initialize upgrades dict - called after UpgradeData is available
	for key in UpgradeData.get_upgrade_ids():
		if not upgrades.has(key):
			upgrades[key] = 0


func add_gold(amount: float) -> void:
	var bonus = get_ascension_bonus()
	var final_amount = amount * bonus
	gold += final_amount
	total_gold_earned += final_amount
	
	if gold > highest_gold_ever:
		highest_gold_ever = gold
	
	GameEvents.gold_changed.emit(gold)


func get_ascension_bonus() -> float:
	var bonus = 1.0
	bonus += ascension_upgrades.get("soul_power", 0) * 0.10
	bonus += ascension_upgrades.get("soul_income", 0) * 0.10
	bonus += ancient_souls * 0.01
	return bonus


func reset() -> void:
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
	total_items_forged = 0
	pending_achievement_rewards = 0.0
	last_save_timestamp = 0.0
	
	for key in items_forged:
		items_forged[key] = 0
	
	for key in weapon_multipliers:
		weapon_multipliers[key] = 1.0
	
	for key in weapon_upgrade_levels:
		weapon_upgrade_levels[key] = 0
	
	for key in upgrades:
		upgrades[key] = 0
	
	for key in ascension_upgrades:
		ascension_upgrades[key] = 0
	
	total_multipliers_purchased = 0
	auto_buy_enabled = false
	auto_ascend_enabled = false
	auto_ascend_threshold = 2.0
	# Note: game_completed is NOT reset - it's permanent
	discovered_upgrades.clear()
	unlocked_achievements.clear()
	shown_milestones.clear()
	ui_scale = 1.0


# Utility functions for formatting
static func format_number(num: float) -> String:
	if num >= 1000000000:
		var exponent = int(log(num) / log(10))
		var mantissa = num / pow(10, exponent)
		return "%.2fe%d" % [mantissa, exponent]
	elif num >= 1000000:
		return "%.2fM" % (num / 1000000.0)
	elif num >= 1000:
		return "%.1fK" % (num / 1000.0)
	else:
		return "%.0f" % num


static func format_souls(num: int) -> String:
	if num >= 1000000000:
		var exponent = int(log(float(num)) / log(10))
		var mantissa = float(num) / pow(10, exponent)
		return "%.2fe%d" % [mantissa, exponent]
	elif num >= 1000000:
		return "%.2fM" % (float(num) / 1000000.0)
	elif num >= 1000:
		return "%.1fK" % (float(num) / 1000.0)
	else:
		return "%d" % num


func get_formatted_gold() -> String:
	return format_number(gold)
