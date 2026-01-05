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
## WEAPON LORE - Backstories for each weapon type
## ============================================

const WEAPON_LORE := {
	"sword": {
		"name": "The Blade of Beginnings",
		"origin": "The sword was the first weapon forged by Valdris himself, shaped from a fallen star.",
		"legend": "Every great smith must master the sword before any other weapon. It is said that those who truly understand the blade can hear the whispers of Valdris in every strike.",
		"unlock_message": "The ancient anvil recognizes you. The path of the sword is now open.",
	},
	"dagger": {
		"name": "Shadow's Kiss",
		"origin": "Born from the need for swift justice, daggers were first crafted by the Night Wardens of old Aethermoor.",
		"legend": "A dagger forged with true skill can find its mark through any armor, guided by the spirits of those who wielded such blades before.",
		"unlock_message": "Your first ascension has awakened the secrets of the dagger. The shadows welcome you.",
	},
	"axe": {
		"name": "Thundercleave",
		"origin": "The mountain clans brought the art of axe-craft to the Eternal Forge, their techniques forged in storms.",
		"legend": "An axe splits more than wood and bone—it cleaves through the veil between worlds, channeling raw elemental fury.",
		"unlock_message": "The mountain spirits acknowledge your dedication. The axe's power is yours to command.",
	},
	"bow": {
		"name": "Whisperwind",
		"origin": "Elven smiths from the Silverwood contributed their secrets, teaching mortals to forge weapons that bend light and air.",
		"legend": "A master-forged bow never misses its true target, for the spirits guide every arrow to its destined mark.",
		"unlock_message": "The wind carries tales of your skill. The art of the bow reveals itself to you.",
	},
	"spear": {
		"name": "Dragonpiercer",
		"origin": "The first spears were forged to slay the great wyrms that once terrorized Aethermoor.",
		"legend": "They say a spear forged at the Eternal Forge can pierce the scales of any dragon, and reach the hearts of gods.",
		"unlock_message": "You have proven your worth through many ascensions. The spear's legacy is now yours.",
	},
	"mace": {
		"name": "Doomhammer",
		"origin": "Temple guardians created the first maces, weapons blessed to shatter both bone and dark magic.",
		"legend": "A mace forged with pure intent can break any curse, crush any evil, and protect the innocent from harm.",
		"unlock_message": "The temple spirits bless your craft. The mace shall be your shield against darkness.",
	},
	"staff": {
		"name": "The Eternal Conduit",
		"origin": "The rarest of weapons, staves channel pure magical energy through specially treated metals and enchanted wood.",
		"legend": "Only the greatest smiths can forge a true staff, for it requires binding a fragment of one's own soul into the creation.",
		"unlock_message": "You have achieved mastery beyond measure. The staff, the ultimate test, awaits your hammer.",
	},
}

## ============================================
## MILESTONE NARRATIVES - Story beats for progression
## ============================================

const MILESTONE_NARRATIVES := {
	"first_forge": {
		"title": "The Journey Begins",
		"text": "The hammer falls. The metal sings. Your first creation takes shape upon the ancient anvil. It is humble work, but every legend must have its beginning.",
		"quote": "\"A single spark can ignite a thousand forges.\" - Master Thornwick",
	},
	"100_forged": {
		"title": "The Apprentice Rises",
		"text": "One hundred weapons bear your mark. The spirits of the forge have taken notice—your dedication does not go unseen in this realm.",
		"quote": "\"Skill is forged through repetition, but mastery is forged through understanding.\" - The First Smith",
	},
	"first_rare": {
		"title": "A Glimmer of Excellence",
		"text": "From ordinary iron, something extraordinary emerges. This weapon shimmers with a quality that transcends mere craftsmanship.",
		"quote": "\"The metal knows when it is in capable hands.\" - Ancient Proverb",
	},
	"first_epic": {
		"title": "The Spirits Speak",
		"text": "The ancient souls stir within the forge. Your creation pulses with otherworldly energy—a weapon touched by powers beyond the mortal realm.",
		"quote": "\"When the spirits whisper, the wise smith listens.\" - Temple of the Forge",
	},
	"first_legendary": {
		"title": "Legend Made Manifest",
		"text": "This is no mere weapon. This is a legend given form, a story waiting to be written in the blood of your enemies. Heroes will quest for centuries to wield what you have created.",
		"quote": "\"Some weapons are forged. Others are destined.\" - Valdris, the First Smith",
	},
	"first_ascension": {
		"title": "The Rite of Rebirth",
		"text": "The flames consume your worldly gains, but from the ashes, something greater emerges. You have touched the realm of spirits and returned transformed. The Ancient Souls now flow through your very being.",
		"quote": "\"To ascend is not to leave behind, but to carry forward the essence of all that was.\" - The Eternal Codex",
	},
	"10_ascensions": {
		"title": "Spirit Walker",
		"text": "Ten times you have passed through the flames. The boundary between worlds grows thin around you. Other smiths speak your name in reverent whispers.",
		"quote": "\"Those who walk between worlds see truths hidden from mortal eyes.\" - Spirit of the Forge",
	},
	"master_smith": {
		"title": "Master of the Eternal Forge",
		"text": "The forge recognizes you not as an apprentice, not as a journeyman, but as a true Master. The spirits bow to your skill. Kings send emissaries to beg for your creations. Legends are written about your works.",
		"quote": "\"In ten thousand years, only a handful have achieved what you now possess.\" - The Ancient Ones",
	},
}

## ============================================
## ASCENSION MILESTONES
## ============================================

const ASCENSION_MILESTONES := {
	1: {
		"title": "First Steps Beyond",
		"message": "You have crossed the threshold. The dagger, weapon of shadows, is now yours to forge.",
	},
	2: {
		"title": "Path of Power",
		"message": "The mountain spirits acknowledge you. The axe's fury awaits your command.",
	},
	3: {
		"title": "Wind Walker",
		"message": "The elven secrets are revealed. The bow shall sing in your hands.",
	},
	5: {
		"title": "Dragon's Bane",
		"message": "You have proven yourself against all odds. The spear's ancient power is unlocked.",
	},
	7: {
		"title": "Temple Guardian",
		"message": "The sacred protectors accept you. The mace shall be your instrument of justice.",
	},
	10: {
		"title": "Arcane Master",
		"message": "You have achieved what few dare dream. The staff, pinnacle of smithing, answers your call.",
	},
	25: {
		"title": "Living Legend",
		"message": "Your name echoes through the ages. Even the gods speak of your works.",
	},
	50: {
		"title": "Eternal Smith",
		"message": "You have transcended mortality. Your forge burns with the fire of creation itself.",
	},
	100: {
		"title": "One With The Forge",
		"message": "The Eternal Forge and you are one. Reality reshapes itself around your anvil.",
	},
}

## ============================================
## NPC QUOTES (for future expansion)
## ============================================

const NPC_QUOTES := {
	"merchant": [
		"Fine work! The nobles will pay handsomely for these.",
		"I've never seen such craftsmanship outside the royal armory.",
		"My customers ask for your work by name now.",
		"The kingdom's finest warriors seek your blades.",
		"Even the royal smith asks where you learned your craft.",
	],
	"spirit": [
		"We remember the First Smith. You carry his spark.",
		"The flames recognize your dedication.",
		"Forge on, young master. Eternity watches.",
		"Your soul burns brighter with each creation.",
		"The ancient ones smile upon your work.",
	],
	"apprentice": [
		"Master, how do you make it look so easy?",
		"I hope to forge half as well as you someday.",
		"The other apprentices speak of you with awe.",
		"Will you teach me the secret of the eternal flames?",
		"I saw the spirits dancing around your last creation!",
	],
}

## ============================================
## RANDOM LORE SNIPPETS (for loading screens, transitions)
## ============================================

const LORE_SNIPPETS: Array[String] = [
	"The Eternal Forge has burned for ten thousand years, waiting for a worthy smith.",
	"Valdris, the First Smith, forged the sun itself, or so the legends claim.",
	"Ancient Souls are fragments of master smiths who chose to remain, guiding future generations.",
	"The metal of Aethermoor remembers. Every weapon carries echoes of its creation.",
	"Some say the hammer's ring can be heard across all realms when a legendary weapon is born.",
	"The greatest weapons are not made—they are awakened from slumber within the metal.",
	"In the old tongue, 'blacksmith' translates to 'shaper of destinies.'",
	"The Eternal Forge exists in all times simultaneously. Past, present, and future are one at the anvil.",
	"Weapons forged with true mastery develop consciousness over centuries.",
	"The fire of the Eternal Forge burns without fuel, fed by ambition and dedication alone.",
	"Master Thornwick was said to hear the metal speak, telling him its true form.",
	"The spirits choose who may ascend. Wealth alone cannot buy their favor.",
	"Each tier of quality represents a deeper connection to the spiritual realm.",
	"The boundary between smith and weapon blurs with each ascension.",
	"In Aethermoor, the finest blade is worth more than a kingdom.",
]

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


static func get_weapon_lore(weapon_id: String) -> Dictionary:
	if WEAPON_LORE.has(weapon_id):
		return WEAPON_LORE[weapon_id]
	return {}


static func get_weapon_legend(weapon_id: String) -> String:
	if WEAPON_LORE.has(weapon_id):
		return WEAPON_LORE[weapon_id].get("legend", "")
	return ""


static func get_weapon_unlock_message(weapon_id: String) -> String:
	if WEAPON_LORE.has(weapon_id):
		return WEAPON_LORE[weapon_id].get("unlock_message", "")
	return ""


static func get_milestone_narrative(milestone_key: String) -> Dictionary:
	if MILESTONE_NARRATIVES.has(milestone_key):
		return MILESTONE_NARRATIVES[milestone_key]
	return {}


static func get_ascension_milestone(ascension_count: int) -> Dictionary:
	if ASCENSION_MILESTONES.has(ascension_count):
		return ASCENSION_MILESTONES[ascension_count]
	return {}


static func get_random_lore_snippet() -> String:
	return LORE_SNIPPETS[randi() % LORE_SNIPPETS.size()]


static func get_random_npc_quote(npc_type: String) -> String:
	if NPC_QUOTES.has(npc_type):
		var quotes = NPC_QUOTES[npc_type]
		return quotes[randi() % quotes.size()]
	return ""
