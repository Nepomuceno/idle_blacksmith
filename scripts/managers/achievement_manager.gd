class_name AchievementManager
extends RefCounted
## Handles achievement tracking and unlocking

const AchievementData = preload("res://scripts/data/achievement_data.gd")
const WeaponData = preload("res://scripts/data/weapon_data.gd")

var game_state


func _init(state) -> void:
	game_state = state


func check_all() -> void:
	_check_forge_achievements()
	_check_gold_achievements()
	_check_tier_achievements()
	_check_ascension_achievements()


func _check_forge_achievements() -> void:
	_try_unlock("first_forge", game_state.total_items_forged >= 1)
	_try_unlock("forge_10", game_state.total_items_forged >= 10)
	_try_unlock("forge_100", game_state.total_items_forged >= 100)
	_try_unlock("forge_1000", game_state.total_items_forged >= 1000)
	_try_unlock("forge_10000", game_state.total_items_forged >= 10000)


func _check_gold_achievements() -> void:
	var total_ever = game_state.lifetime_gold + game_state.total_gold_earned
	_try_unlock("gold_100", total_ever >= 100)
	_try_unlock("gold_1k", total_ever >= 1000)
	_try_unlock("gold_10k", total_ever >= 10000)
	_try_unlock("gold_100k", total_ever >= 100000)
	_try_unlock("gold_1m", total_ever >= 1000000)


func _check_tier_achievements() -> void:
	_try_unlock("tier_uncommon", game_state.unlocked_tier >= 1)
	_try_unlock("tier_rare", game_state.unlocked_tier >= 2)
	_try_unlock("tier_epic", game_state.unlocked_tier >= 3)
	_try_unlock("tier_legendary", game_state.unlocked_tier >= 4)


func _check_ascension_achievements() -> void:
	_try_unlock("first_ascend", game_state.total_ascensions >= 1)
	_try_unlock("ascend_5", game_state.total_ascensions >= 5)
	_try_unlock("ascend_10", game_state.total_ascensions >= 10)


func check_weapon_unlocks(forge_manager) -> void:
	if forge_manager.is_weapon_unlocked("dagger"):
		_try_unlock("unlock_dagger", true)
	if forge_manager.is_weapon_unlocked("axe"):
		_try_unlock("unlock_axe", true)
	if forge_manager.is_weapon_unlocked("bow"):
		_try_unlock("unlock_bow", true)
	
	# Check if all weapons unlocked
	var all_unlocked = true
	for weapon_id in WeaponData.get_weapon_ids():
		if not forge_manager.is_weapon_unlocked(weapon_id):
			all_unlocked = false
			break
	if all_unlocked:
		_try_unlock("unlock_all", true)


func _try_unlock(achievement_id: String, condition: bool) -> void:
	if condition and achievement_id not in game_state.unlocked_achievements:
		game_state.unlocked_achievements.append(achievement_id)
		var reward = AchievementData.get_reward(achievement_id)
		if reward > 0:
			game_state.pending_achievement_rewards += reward
		GameEvents.achievement_unlocked.emit(achievement_id)


func is_unlocked(achievement_id: String) -> bool:
	return achievement_id in game_state.unlocked_achievements


func get_unlocked() -> Array:
	var unlocked = []
	for achievement_id in game_state.unlocked_achievements:
		if achievement_id in AchievementData.ACHIEVEMENTS:
			unlocked.append(achievement_id)
	return unlocked


func get_locked() -> Array:
	var locked = []
	for achievement_id in AchievementData.get_achievement_ids():
		if achievement_id not in game_state.unlocked_achievements:
			locked.append(achievement_id)
	return locked


func get_progress() -> Dictionary:
	var total = AchievementData.get_total_count()
	var unlocked = get_unlocked().size()
	return {
		"unlocked": unlocked,
		"total": total,
		"percent": float(unlocked) / float(total) * 100.0
	}


func claim_rewards() -> float:
	var rewards = game_state.pending_achievement_rewards
	if rewards > 0:
		game_state.gold += rewards
		game_state.pending_achievement_rewards = 0.0
		GameEvents.gold_changed.emit(game_state.gold)
		GameEvents.achievement_rewards_claimed.emit(rewards)
	return rewards
