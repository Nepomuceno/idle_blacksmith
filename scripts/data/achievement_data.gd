class_name AchievementData
extends RefCounted
## Static achievement definitions

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
	"ascend_25": {"name": "Timeless Master", "desc": "Ascend 25 times", "icon": "S_Holy01.png", "reward": 0},
	"ascend_50": {"name": "Cosmic Smith", "desc": "Ascend 50 times", "icon": "S_Holy02.png", "reward": 0},
	"ascend_100": {"name": "Eternal Legend", "desc": "Ascend 100 times", "icon": "S_Light02.png", "reward": 0},
	
	# Soul milestones
	"souls_10": {"name": "Soul Collector", "desc": "Accumulate 10 Ancient Souls", "icon": "S_Dark01.png", "reward": 0},
	"souls_100": {"name": "Soul Hoarder", "desc": "Accumulate 100 Ancient Souls", "icon": "S_Dark02.png", "reward": 0},
	"souls_1000": {"name": "Soul Master", "desc": "Accumulate 1,000 Ancient Souls", "icon": "S_Dark03.png", "reward": 0},
	"souls_10000": {"name": "Soul Emperor", "desc": "Accumulate 10,000 Ancient Souls", "icon": "S_Dark04.png", "reward": 0},
	
	# Automation achievements
	"unlock_auto_buy": {"name": "Hands Free", "desc": "Unlock Auto-Buy", "icon": "E_Metal02.png", "reward": 0},
	"unlock_auto_ascend": {"name": "Infinite Loop", "desc": "Unlock Auto-Ascend", "icon": "I_Clock.png", "reward": 0},
	
	# Ultimate
	"game_complete": {"name": "Cosmic Mastery", "desc": "Complete the game", "icon": "S_Light02.png", "reward": 0},
	
	# Weapon unlocks
	"unlock_dagger": {"name": "Swift Blade", "desc": "Unlock the Dagger", "icon": "W_Dagger010.png", "reward": 0},
	"unlock_axe": {"name": "Heavy Hitter", "desc": "Unlock the Axe", "icon": "W_Axe007.png", "reward": 0},
	"unlock_bow": {"name": "Ranger's Choice", "desc": "Unlock the Bow", "icon": "W_Bow07.png", "reward": 0},
	"unlock_all": {"name": "Arsenal Complete", "desc": "Unlock all weapons", "icon": "E_Metal03.png", "reward": 0}
}


static func get_achievement(achievement_id: String) -> Dictionary:
	return ACHIEVEMENTS.get(achievement_id, {})


static func get_achievement_ids() -> Array:
	return ACHIEVEMENTS.keys()


static func get_reward(achievement_id: String) -> float:
	return ACHIEVEMENTS.get(achievement_id, {}).get("reward", 0)


static func get_total_count() -> int:
	return ACHIEVEMENTS.size()
