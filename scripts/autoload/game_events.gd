extends Node
## Centralized event bus for game-wide signals
## Access via GameEvents autoload

# Currency events
signal gold_changed(new_amount: float)
signal gold_earned(amount: float)

# Forge events
signal item_forged(weapon_id: String, tier: int, value: float)
signal weapon_selected(weapon_id: String)

# Upgrade events
signal upgrade_purchased(upgrade_id: String, new_level: int)
signal upgrade_visibility_changed()

# Achievement events
signal achievement_unlocked(achievement_id: String)
signal achievement_rewards_claimed(amount: float)

# Ascension events
signal ascension_available()
signal ascended(souls_earned: int)
signal soul_upgrade_purchased(upgrade_id: String)
signal weapon_upgrade_purchased(weapon_id: String)

# UI events
signal tab_changed(tab_name: String)
signal layout_changed(is_wide: bool)

# Save/Load events
signal game_saved()
signal game_loaded()
signal game_reset()

# Audio events
signal play_sound(sound_type: String)
