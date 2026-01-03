## Lore Data for Idle Blacksmith
## Contains all story, world-building, and flavor text for the game

extends RefCounted
class_name LoreData

## ============================================
## WORLD LORE
## ============================================

const WORLD_NAME := "Aethermoor"

const WORLD_DESCRIPTION := """
Aethermoor is a realm where the boundary between the mortal world and the spirit realm 
grows thin. Here, master craftsmen don't merely shape metal—they channel the essence 
of ancient souls into their creations, forging weapons that carry the memories and 
power of those who came before.

The Eternal Forge, a sacred site older than any kingdom, stands at the heart of this 
land. Its flames have never dimmed, fed by the collective ambition of every smith 
who has ever worked its anvil. Legends say the forge was created by Valdris, the 
First Smith, who struck a bargain with the spirits of fire and iron to create weapons 
worthy of the gods themselves.
"""

## ============================================
## THE PLAYER'S STORY
## ============================================

const PLAYER_BACKSTORY := """
You are the last apprentice of Master Thornwick, a legendary blacksmith whose weapons 
were sought by kings and heroes across all the realms. On his deathbed, he entrusted 
you with the key to the Eternal Forge—a place he had only spoken of in whispers.

"The forge chooses its master," he said with his final breath. "Prove yourself worthy, 
and the ancient souls will share their secrets. Fail, and you will be forgotten like 
the countless others who tried before."

Now you stand before the ancient anvil, hammer in hand, ready to begin your journey 
from humble apprentice to legendary master smith.
"""

## ============================================
## WEAPON TIER LORE
## ============================================

const TIER_LORE := {
	"common": {
		"name": "Common",
		"description": "Simple weapons forged from basic iron. Every master began here.",
		"flavor": "The foundation of all craft. Even legendary smiths remember their first blade.",
	},
	"uncommon": {
		"name": "Uncommon", 
		"description": "Refined weapons showing the first sparks of true skill.",
		"flavor": "The iron begins to listen. Your hammer strikes grow more confident.",
	},
	"rare": {
		"name": "Rare",
		"description": "Quality weapons that catch the eye of discerning warriors.",
		"flavor": "Word spreads of your talent. Merchants travel far to see your work.",
	},
	"epic": {
		"name": "Epic",
		"description": "Exceptional arms imbued with the first whispers of ancient power.",
		"flavor": "The spirits take notice. Faint echoes guide your hammer's fall.",
	},
	"legendary": {
		"name": "Legendary",
		"description": "Weapons of myth, each one carrying the soul of a fallen hero.",
		"flavor": "The ancient souls speak clearly now. Their power flows through your forge.",
	},
	"mythic": {
		"name": "Mythic",
		"description": "Arms that transcend mortal craft, blessed by the spirits themselves.",
		"flavor": "Reality bends around these weapons. Even gods would covet such creations.",
	},
	"divine": {
		"name": "Divine",
		"description": "Weapons forged at the boundary of worlds, containing fragments of eternity.",
		"flavor": "You have touched the infinite. The forge recognizes you as a true master.",
	},
	"eternal": {
		"name": "Eternal",
		"description": "The pinnacle of all smithing. Weapons that will outlast the stars.",
		"flavor": "Valdris himself would weep with pride. You have surpassed even the First Smith.",
	},
}

## ============================================
## ASCENSION LORE
## ============================================

const ASCENSION_INTRO := """
The Ancient Souls have deemed you worthy. Your mastery of the forge has awakened 
powers long dormant within the Eternal Anvil. 

Through the Rite of Ascension, you may sacrifice your worldly gains to absorb 
fragments of the souls that dwell within the forge. Each ascension brings you 
closer to the spirits, granting permanent blessings that transcend the mortal realm.

But beware—ascending means starting anew. Your gold, your upgrades, your progress... 
all will be consumed by the flames. Only the wisdom gained from Ancient Souls remains.
"""

const SOUL_UPGRADE_LORE := {
	"soul_power": {
		"name": "Hammer of Spirits",
		"description": "The ancient souls lend strength to your strikes.",
		"flavor": "Each blow carries the weight of a thousand master smiths.",
	},
	"soul_income": {
		"name": "Merchant's Blessing",
		"description": "The spirits guide wealthy patrons to your forge.",
		"flavor": "Gold flows like water to those favored by the ancients.",
	},
	"soul_luck": {
		"name": "Fortune's Whisper",
		"description": "The spirits reveal the secrets of rare materials.",
		"flavor": "You see the potential in metal that others would overlook.",
	},
	"soul_forge": {
		"name": "Eternal Flames",
		"description": "The forge burns hotter, working metal with supernatural speed.",
		"flavor": "Time itself bends around your anvil.",
	},
}

## ============================================
## ACHIEVEMENT FLAVOR TEXT
## ============================================

const ACHIEVEMENT_FLAVOR := {
	"first_forge": "Every legend begins with a single strike.",
	"gold_hoarder": "The merchants speak your name with reverence and envy.",
	"weapon_master": "Your armory would make kings weep with desire.",
	"ascended": "You have touched the realm beyond and returned changed.",
	"speed_demon": "Your hammer moves faster than mortal eyes can follow.",
	"completionist": "Nothing escapes your tireless pursuit of mastery.",
}

## ============================================
## RANDOM FORGE QUOTES
## ============================================

const FORGE_QUOTES: Array[String] = [
	"The metal sings beneath your hammer.",
	"Ancient spirits guide your hand.",
	"The forge burns bright with purpose.",
	"Another masterpiece takes shape.",
	"The anvil rings with the sound of destiny.",
	"Fire and iron bend to your will.",
	"The old masters would be proud.",
	"This weapon will write history.",
	"The spirits whisper approval.",
	"Your legend grows with every strike.",
]

## ============================================
## TIPS & HINTS
## ============================================

const LOADING_TIPS: Array[String] = [
	"Higher tier weapons are worth exponentially more gold.",
	"Upgrades become more cost-effective as you progress.",
	"Ancient Souls provide permanent bonuses across all ascensions.",
	"Auto-forge continues working even when you're away.",
	"Ascending resets progress but multiplies your power.",
	"Each weapon type can be individually upgraded in the Soul Shop.",
	"The forge never sleeps. Your passive income works around the clock.",
	"Legendary weapons can appear at any time—stay vigilant!",
]

## ============================================
## NPC QUOTES (for future expansion)
## ============================================

const NPC_QUOTES := {
	"merchant": [
		"Fine work! The nobles will pay handsomely for these.",
		"I've never seen such craftsmanship outside the royal armory.",
		"My customers ask for your work by name now.",
	],
	"spirit": [
		"We remember the First Smith. You carry his spark.",
		"The flames recognize your dedication.",
		"Forge on, young master. Eternity watches.",
	],
	"apprentice": [
		"Master, how do you make it look so easy?",
		"I hope to forge half as well as you someday.",
		"The other apprentices speak of you with awe.",
	],
}

## ============================================
## HELPER FUNCTIONS
## ============================================

static func get_random_forge_quote() -> String:
	return FORGE_QUOTES[randi() % FORGE_QUOTES.size()]


static func get_random_loading_tip() -> String:
	return LOADING_TIPS[randi() % LOADING_TIPS.size()]


static func get_tier_flavor(tier_key: String) -> String:
	if TIER_LORE.has(tier_key):
		return TIER_LORE[tier_key].get("flavor", "")
	return ""


static func get_tier_description(tier_key: String) -> String:
	if TIER_LORE.has(tier_key):
		return TIER_LORE[tier_key].get("description", "")
	return ""
