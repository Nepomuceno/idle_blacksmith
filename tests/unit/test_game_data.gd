extends GutTest
## Unit tests for GameData class
## Tests cover: currency, upgrades, ascension, achievements, weapons, and save/load

var game_data: GameData

func before_each() -> void:
	game_data = GameData.new()
	add_child(game_data)

func after_each() -> void:
	game_data.queue_free()


# ========== CURRENCY TESTS ==========

func test_initial_gold_is_zero() -> void:
	assert_eq(game_data.gold, 0.0, "Initial gold should be 0")

func test_add_gold_increases_balance() -> void:
	game_data.add_gold(100.0)
	assert_eq(game_data.gold, 100.0, "Gold should be 100 after adding 100")

func test_add_gold_updates_total_earned() -> void:
	game_data.add_gold(50.0)
	game_data.add_gold(75.0)
	assert_eq(game_data.total_gold_earned, 125.0, "Total gold earned should track all additions")

func test_add_gold_updates_highest_gold_ever() -> void:
	game_data.add_gold(200.0)
	game_data.gold = 50.0  # Simulate spending
	game_data.add_gold(100.0)
	assert_eq(game_data.highest_gold_ever, 200.0, "Highest gold should remain at peak value")

func test_add_gold_emits_gold_changed_signal() -> void:
	watch_signals(game_data)
	game_data.add_gold(10.0)
	assert_signal_emitted(game_data, "gold_changed", "gold_changed signal should emit when gold is added")


# ========== NUMBER FORMATTING TESTS ==========

func test_format_number_below_thousand() -> void:
	assert_eq(game_data.format_number(500.0), "500", "Numbers below 1000 should show as integers")

func test_format_number_thousands() -> void:
	assert_eq(game_data.format_number(5500.0), "5.5K", "5500 should format as 5.5K")

func test_format_number_millions() -> void:
	assert_eq(game_data.format_number(2500000.0), "2.50M", "2.5M should format correctly")

func test_format_number_billions() -> void:
	assert_eq(game_data.format_number(3000000000.0), "3.00B", "3B should format correctly")

func test_format_number_scientific() -> void:
	var result = game_data.format_number(500000000000.0)
	assert_true(result.contains("e"), "Very large numbers should use scientific notation")


# ========== UPGRADE TESTS ==========

func test_initial_upgrades_are_zero() -> void:
	for key in game_data.UPGRADE_DATA:
		assert_eq(game_data.upgrades.get(key, 0), 0, "All upgrades should start at level 0")

func test_get_upgrade_cost_base() -> void:
	var cost = game_data.get_upgrade_cost("better_anvil")
	assert_eq(cost, 15.0, "better_anvil base cost should be 15")

func test_get_upgrade_cost_scaling() -> void:
	game_data.upgrades["better_anvil"] = 1
	var cost = game_data.get_upgrade_cost("better_anvil")
	# Cost = base * multiplier^level = 15 * 2.5^1 = 37.5
	assert_almost_eq(cost, 37.5, 0.01, "Upgrade cost should scale with level")

func test_purchase_upgrade_success() -> void:
	game_data.gold = 100.0
	var result = game_data.purchase_upgrade("better_anvil")
	assert_true(result, "Purchase should succeed with enough gold")
	assert_eq(game_data.upgrades["better_anvil"], 1, "Upgrade level should increase")

func test_purchase_upgrade_insufficient_gold() -> void:
	game_data.gold = 5.0
	var result = game_data.purchase_upgrade("better_anvil")
	assert_false(result, "Purchase should fail without enough gold")
	assert_eq(game_data.upgrades["better_anvil"], 0, "Upgrade level should remain 0")

func test_purchase_upgrade_deducts_gold() -> void:
	game_data.gold = 100.0
	game_data.purchase_upgrade("better_anvil")
	assert_eq(game_data.gold, 85.0, "Gold should be reduced by upgrade cost")

func test_upgrade_max_level_enforced() -> void:
	game_data.gold = 1000000.0
	game_data.upgrades["enchanted_forge"] = 1  # Max level is 1
	var result = game_data.purchase_upgrade("enchanted_forge")
	assert_false(result, "Should not be able to purchase beyond max level")

func test_is_upgrade_maxed() -> void:
	game_data.upgrades["enchanted_forge"] = 1
	assert_true(game_data.is_upgrade_maxed("enchanted_forge"), "Upgrade at max level should return true")
	assert_false(game_data.is_upgrade_maxed("better_anvil"), "Unlimited upgrade should never be maxed")

func test_upgrade_effects_click_power() -> void:
	var initial_click = game_data.click_power
	game_data.gold = 100.0
	game_data.purchase_upgrade("better_anvil")
	assert_gt(game_data.click_power, initial_click, "Click power should increase after better_anvil")

func test_upgrade_effects_passive_income() -> void:
	game_data.gold = 500.0
	game_data.purchase_upgrade("apprentice")
	assert_gt(game_data.passive_income, 0.0, "Passive income should increase after apprentice")

func test_upgrade_effects_auto_forge() -> void:
	game_data.gold = 500.0
	game_data.purchase_upgrade("auto_forge")
	assert_gt(game_data.auto_forge_rate, 0.0, "Auto-forge rate should increase after auto_forge upgrade")

func test_diminishing_returns() -> void:
	# First purchase gives full effect
	var effect1 = game_data.get_upgrade_effect("better_anvil")
	game_data.upgrades["better_anvil"] = 1
	var effect2 = game_data.get_upgrade_effect("better_anvil")
	assert_lt(effect2, effect1, "Subsequent upgrade effects should be diminished")
	assert_almost_eq(effect2, effect1 * 0.85, 0.01, "Diminishing factor should be 0.85")


# ========== UPGRADE VISIBILITY TESTS ==========

func test_upgrade_visibility_based_on_gold() -> void:
	# better_anvil has base_cost 15, visibility 0.3 -> shows at 4.5 gold
	game_data.highest_gold_ever = 5.0
	assert_true(game_data.is_upgrade_visible("better_anvil"), "Upgrade should be visible when gold threshold met")

func test_upgrade_not_visible_before_threshold() -> void:
	game_data.highest_gold_ever = 1.0
	# Clear discovered to ensure fresh check
	game_data.discovered_upgrades.clear()
	assert_false(game_data.is_upgrade_visible("apprentice"), "Expensive upgrade should not be visible early")

func test_purchased_upgrade_always_visible() -> void:
	game_data.upgrades["better_anvil"] = 1
	assert_true(game_data.is_upgrade_visible("better_anvil"), "Purchased upgrade should always be visible")


# ========== WEAPON TESTS ==========

func test_sword_always_unlocked() -> void:
	assert_true(game_data.is_weapon_unlocked("sword"), "Sword should always be unlocked")

func test_dagger_requires_ascension() -> void:
	assert_false(game_data.is_weapon_unlocked("dagger"), "Dagger should not be unlocked without ascension")
	game_data.total_ascensions = 1
	assert_true(game_data.is_weapon_unlocked("dagger"), "Dagger should unlock after 1 ascension")

func test_get_unlocked_weapons_initial() -> void:
	var unlocked = game_data.get_unlocked_weapons()
	assert_eq(unlocked.size(), 1, "Only sword should be unlocked initially")
	assert_true("sword" in unlocked, "Sword should be in unlocked weapons")

func test_get_weapon_value() -> void:
	var value = game_data.get_weapon_value("sword")
	# Base sword value is 1.0, multiplier is 1.0, click_power is 1.0
	assert_eq(value, 1.0, "Initial sword value should be 1.0")

func test_weapon_multiplier_affects_value() -> void:
	game_data.weapon_multipliers["sword"] = 2.0
	var value = game_data.get_weapon_value("sword")
	assert_eq(value, 2.0, "Weapon multiplier should affect value")

func test_select_weapon() -> void:
	game_data.total_ascensions = 1  # Unlock dagger
	game_data.select_weapon("dagger")
	assert_eq(game_data.selected_weapon, "dagger", "Selected weapon should change")

func test_select_locked_weapon_fails() -> void:
	game_data.select_weapon("staff")  # Requires 10 ascensions
	assert_eq(game_data.selected_weapon, "sword", "Cannot select locked weapon")

func test_weapon_upgrade_cost() -> void:
	var cost = game_data.get_weapon_upgrade_cost("sword")
	assert_eq(cost, 3, "Initial weapon upgrade cost should be 3 souls")

func test_weapon_upgrade_cost_scaling() -> void:
	game_data.weapon_upgrade_levels["sword"] = 1
	var cost = game_data.get_weapon_upgrade_cost("sword")
	# 3 * 1.5^1 = 4.5 -> int = 4
	assert_eq(cost, 4, "Weapon upgrade cost should scale")

func test_purchase_weapon_upgrade() -> void:
	game_data.ancient_souls = 10
	var result = game_data.purchase_weapon_upgrade("sword")
	assert_true(result, "Should be able to purchase weapon upgrade")
	assert_eq(game_data.weapon_upgrade_levels["sword"], 1, "Weapon level should increase")
	assert_eq(game_data.weapon_multipliers["sword"], 1.25, "Multiplier should increase by 25%")

func test_purchase_weapon_upgrade_insufficient_souls() -> void:
	game_data.ancient_souls = 1
	var result = game_data.purchase_weapon_upgrade("sword")
	assert_false(result, "Should not purchase without enough souls")


# ========== ASCENSION TESTS ==========

func test_can_ascend_false_initially() -> void:
	assert_false(game_data.can_ascend(), "Should not be able to ascend with no gold")

func test_can_ascend_at_threshold() -> void:
	game_data.total_gold_earned = 100000.0
	assert_true(game_data.can_ascend(), "Should be able to ascend at threshold")

func test_get_souls_on_ascension() -> void:
	game_data.total_gold_earned = 100000.0
	var souls = game_data.get_souls_on_ascension()
	# sqrt(100000 / 10000) = sqrt(10) ≈ 3.16 -> int = 3
	assert_eq(souls, 3, "Souls should be calculated correctly")

func test_ascend_increases_souls() -> void:
	game_data.total_gold_earned = 100000.0
	game_data.gold = 50000.0
	game_data.ascend()
	assert_gt(game_data.ancient_souls, 0, "Should gain souls after ascension")

func test_ascend_increments_total_ascensions() -> void:
	game_data.total_gold_earned = 100000.0
	game_data.ascend()
	assert_eq(game_data.total_ascensions, 1, "Total ascensions should increase")

func test_ascend_resets_gold() -> void:
	game_data.total_gold_earned = 100000.0
	game_data.gold = 50000.0
	game_data.ascend()
	assert_eq(game_data.gold, 0.0, "Gold should reset after ascension")

func test_ascend_resets_upgrades() -> void:
	game_data.total_gold_earned = 100000.0
	game_data.upgrades["better_anvil"] = 5
	game_data.ascend()
	assert_eq(game_data.upgrades["better_anvil"], 0, "Upgrades should reset after ascension")

func test_ascend_preserves_ancient_souls() -> void:
	game_data.ancient_souls = 10
	game_data.total_gold_earned = 100000.0
	var souls_before = game_data.ancient_souls
	game_data.ascend()
	assert_gt(game_data.ancient_souls, souls_before, "Ancient souls should accumulate")

func test_ascend_preserves_weapon_multipliers() -> void:
	game_data.weapon_multipliers["sword"] = 2.0
	game_data.total_gold_earned = 100000.0
	game_data.ascend()
	assert_eq(game_data.weapon_multipliers["sword"], 2.0, "Weapon multipliers should persist")

func test_ascend_emits_signal() -> void:
	game_data.total_gold_earned = 100000.0
	watch_signals(game_data)
	game_data.ascend()
	assert_signal_emitted(game_data, "ascended", "ascended signal should emit")

func test_ascension_bonus_calculation() -> void:
	game_data.ascension_upgrades["soul_power"] = 2
	game_data.ancient_souls = 10
	var bonus = game_data.get_ascension_bonus()
	# 1.0 + 2*0.10 + 10*0.01 = 1.3
	assert_almost_eq(bonus, 1.3, 0.01, "Ascension bonus should be calculated correctly")

func test_purchase_ascension_upgrade() -> void:
	game_data.ancient_souls = 5
	var result = game_data.purchase_ascension_upgrade("soul_power")
	assert_true(result, "Should be able to purchase with enough souls")
	assert_eq(game_data.ascension_upgrades["soul_power"], 1, "Upgrade level should increase")
	assert_eq(game_data.ancient_souls, 4, "Souls should be deducted")


# ========== ACHIEVEMENT TESTS ==========

func test_initial_achievements_empty() -> void:
	assert_eq(game_data.unlocked_achievements.size(), 0, "No achievements unlocked initially")

func test_first_forge_achievement() -> void:
	watch_signals(game_data)
	game_data.total_items_forged = 1
	game_data.check_achievements()
	assert_true("first_forge" in game_data.unlocked_achievements, "first_forge should unlock")
	assert_signal_emitted(game_data, "achievement_unlocked")

func test_achievement_rewards_accumulate() -> void:
	game_data.total_items_forged = 10
	game_data.check_achievements()
	# forge_10 has reward of 5
	assert_gt(game_data.pending_achievement_rewards, 0.0, "Rewards should accumulate")

func test_claim_achievement_rewards() -> void:
	game_data.pending_achievement_rewards = 100.0
	var claimed = game_data.claim_achievement_rewards()
	assert_eq(claimed, 100.0, "Should claim pending rewards")
	assert_eq(game_data.gold, 100.0, "Gold should increase")
	assert_eq(game_data.pending_achievement_rewards, 0.0, "Pending rewards should reset")

func test_achievement_not_duplicated() -> void:
	game_data.total_items_forged = 1
	game_data.check_achievements()
	game_data.check_achievements()
	var count = game_data.unlocked_achievements.count("first_forge")
	assert_eq(count, 1, "Achievement should not be duplicated")

func test_achievement_progress() -> void:
	game_data.total_items_forged = 1
	game_data.check_achievements()
	var progress = game_data.get_achievement_progress()
	assert_gt(progress["unlocked"], 0, "Should have unlocked achievements")
	assert_gt(progress["total"], 0, "Should have total achievements")
	assert_gt(progress["percent"], 0.0, "Percent should be calculated")


# ========== TIER TESTS ==========

func test_initial_tier_is_zero() -> void:
	assert_eq(game_data.unlocked_tier, 0, "Initial tier should be 0 (Common)")

func test_tier_unlocks_at_thresholds() -> void:
	game_data.total_items_forged = 25
	game_data._check_tier_unlocks()
	assert_eq(game_data.unlocked_tier, 1, "Tier 1 should unlock at 25 items")
	
	game_data.total_items_forged = 100
	game_data._check_tier_unlocks()
	assert_eq(game_data.unlocked_tier, 2, "Tier 2 should unlock at 100 items")

func test_get_random_tier_respects_unlocked() -> void:
	# With tier 0, should always get tier 0
	for i in range(10):
		var tier = game_data.get_random_tier()
		assert_eq(tier, 0, "Should only get tier 0 when no tiers unlocked")


# ========== AUTO-FORGE TESTS ==========

func test_effective_auto_forge_rate_base() -> void:
	game_data.auto_forge_rate = 2.0
	var effective = game_data.get_effective_auto_forge_rate()
	assert_eq(effective, 2.0, "Base auto-forge rate should be unchanged")

func test_effective_auto_forge_rate_with_soul_bonus() -> void:
	game_data.auto_forge_rate = 2.0
	game_data.ascension_upgrades["soul_forge"] = 2  # +20% bonus
	var effective = game_data.get_effective_auto_forge_rate()
	assert_almost_eq(effective, 2.4, 0.01, "Soul forge should boost auto-forge rate")


# ========== RESET TESTS ==========

func test_reset_all_progress() -> void:
	# Set up some progress
	game_data.gold = 1000.0
	game_data.ancient_souls = 50
	game_data.total_ascensions = 3
	game_data.upgrades["better_anvil"] = 5
	game_data.unlocked_achievements.append("first_forge")
	
	game_data.reset_all_progress()
	
	assert_eq(game_data.gold, 0.0, "Gold should be reset")
	assert_eq(game_data.ancient_souls, 0, "Ancient souls should be reset")
	assert_eq(game_data.total_ascensions, 0, "Ascensions should be reset")
	assert_eq(game_data.upgrades["better_anvil"], 0, "Upgrades should be reset")
	assert_eq(game_data.unlocked_achievements.size(), 0, "Achievements should be reset")
