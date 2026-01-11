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
var sound_enabled: bool = true

# ========== NEW FEATURES ==========

# Forge Streak/Combo System
var forge_streak: int = 0           # Current consecutive forge count
var forge_streak_timer: float = 0.0  # Time since last forge
var best_streak: int = 0            # Best streak ever achieved
const STREAK_TIMEOUT: float = 2.0    # Seconds before streak resets
const MAX_STREAK_BONUS: float = 0.5  # Max +50% bonus from streaks

# Daily Login Bonus
var daily_login_streak: int = 0     # Consecutive days logged in
var last_login_date: String = ""    # Last login date (YYYY-MM-DD)
var daily_bonus_claimed: bool = false  # Whether today's bonus was claimed

# Weapon Mastery (specialization bonus based on items forged)
# Mastery bonus: +1% per 100 items forged with that weapon
const MASTERY_ITEMS_PER_LEVEL: int = 100
const MASTERY_BONUS_PER_LEVEL: float = 0.01  # +1% per level

# Critical Forge
var crit_chance: float = 0.05       # Base 5% crit chance
var last_forge_was_crit: bool = false
const CRIT_MULTIPLIER: float = 2.0  # Crits give 2x gold


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
	sound_enabled = true
	
	# Reset new features
	forge_streak = 0
	forge_streak_timer = 0.0
	best_streak = 0
	daily_login_streak = 0
	last_login_date = ""
	daily_bonus_claimed = false
	crit_chance = 0.05
	last_forge_was_crit = false


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


# ========== NEW FEATURE HELPERS ==========

## Get streak bonus multiplier (0.0 to MAX_STREAK_BONUS)
func get_streak_bonus() -> float:
	# Each streak level gives +1%, capped at MAX_STREAK_BONUS
	return minf(forge_streak * 0.01, MAX_STREAK_BONUS)


## Get weapon mastery level for a specific weapon
func get_weapon_mastery_level(weapon_id: String) -> int:
	var forged = items_forged.get(weapon_id, 0)
	return forged / MASTERY_ITEMS_PER_LEVEL


## Get weapon mastery bonus multiplier
func get_weapon_mastery_bonus(weapon_id: String) -> float:
	var level = get_weapon_mastery_level(weapon_id)
	return level * MASTERY_BONUS_PER_LEVEL


## Get effective crit chance (includes soul_luck bonus)
func get_effective_crit_chance() -> float:
	var luck_bonus = ascension_upgrades.get("soul_luck", 0) * 0.02  # +2% per soul_luck level
	return minf(crit_chance + luck_bonus, 0.50)  # Cap at 50%


## Get player title based on ascension count
func get_player_title() -> String:
	if total_ascensions >= 100:
		return "One With The Forge"
	elif total_ascensions >= 50:
		return "Eternal Smith"
	elif total_ascensions >= 25:
		return "Living Legend"
	elif total_ascensions >= 10:
		return "Arcane Master"
	elif total_ascensions >= 7:
		return "Temple Guardian"
	elif total_ascensions >= 5:
		return "Dragon's Bane"
	elif total_ascensions >= 3:
		return "Wind Walker"
	elif total_ascensions >= 2:
		return "Path of Power"
	elif total_ascensions >= 1:
		return "Transcended"
	else:
		return "Apprentice Smith"


## Update streak timer - called every frame
func update_streak(delta: float) -> void:
	if forge_streak > 0:
		forge_streak_timer += delta
		if forge_streak_timer >= STREAK_TIMEOUT:
			forge_streak = 0
			forge_streak_timer = 0.0


## Register a manual forge for streak
func register_forge_for_streak() -> void:
	forge_streak += 1
	forge_streak_timer = 0.0
	if forge_streak > best_streak:
		best_streak = forge_streak


## Check and update daily login
func check_daily_login() -> Dictionary:
	var current_date = Time.get_date_string_from_system()
	
	if last_login_date == "":
		# First time playing
		last_login_date = current_date
		daily_login_streak = 1
		daily_bonus_claimed = false
		return {"is_new_day": true, "streak": 1}
	
	if current_date == last_login_date:
		# Same day, nothing to do
		return {"is_new_day": false, "streak": daily_login_streak}
	
	# Calculate days between
	var last_dict = Time.get_datetime_dict_from_datetime_string(last_login_date + "T00:00:00", false)
	var curr_dict = Time.get_datetime_dict_from_datetime_string(current_date + "T00:00:00", false)
	
	var last_unix = Time.get_unix_time_from_datetime_dict(last_dict)
	var curr_unix = Time.get_unix_time_from_datetime_dict(curr_dict)
	var days_diff = int((curr_unix - last_unix) / 86400)
	
	if days_diff == 1:
		# Consecutive day
		daily_login_streak += 1
	else:
		# Streak broken
		daily_login_streak = 1
	
	last_login_date = current_date
	daily_bonus_claimed = false
	return {"is_new_day": true, "streak": daily_login_streak}


## Get daily bonus amount based on streak
func get_daily_bonus() -> Dictionary:
	# Day 1-6: Gold bonus (100 * day)
	# Day 7: 1 Soul + gold
	var day_in_week = ((daily_login_streak - 1) % 7) + 1
	var gold_bonus = 100.0 * day_in_week * (1.0 + total_ascensions * 0.1)
	var soul_bonus = 0
	
	if day_in_week == 7:
		soul_bonus = 1 + (total_ascensions / 10)  # +1 soul per 10 ascensions
	
	return {
		"day": day_in_week,
		"streak": daily_login_streak,
		"gold": gold_bonus,
		"souls": soul_bonus
	}
