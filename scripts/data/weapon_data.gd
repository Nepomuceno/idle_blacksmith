class_name WeaponData
extends RefCounted
## Static weapon definitions and utilities

const WEAPONS: Dictionary = {
	"sword": {
		"name": "Sword",
		"icon": "W_Sword010.png",
		"color": Color(0.8, 0.8, 0.9),
		"symbol": "S"
	},
	"dagger": {
		"name": "Dagger", 
		"icon": "W_Dagger010.png",
		"color": Color(0.6, 0.9, 0.6),
		"symbol": "D"
	},
	"axe": {
		"name": "Axe",
		"icon": "W_Axe007.png",
		"color": Color(0.9, 0.6, 0.5),
		"symbol": "A"
	},
	"bow": {
		"name": "Bow",
		"icon": "W_Bow07.png",
		"color": Color(0.6, 0.8, 0.5),
		"symbol": "B"
	},
	"spear": {
		"name": "Spear",
		"icon": "W_Spear007.png",
		"color": Color(0.7, 0.7, 0.9),
		"symbol": "P"
	},
	"mace": {
		"name": "Mace",
		"icon": "W_Mace007.png",
		"color": Color(0.9, 0.7, 0.5),
		"symbol": "M"
	},
	"staff": {
		"name": "Staff",
		"icon": "W_Staff04.png",
		"color": Color(0.7, 0.5, 0.9),
		"symbol": "T"
	}
}

const BASE_VALUES: Dictionary = {
	"sword": 1.0,
	"dagger": 0.8,
	"axe": 1.2,
	"bow": 1.0,
	"spear": 1.1,
	"mace": 1.3,
	"staff": 1.5
}

const UNLOCK_ASCENSIONS: Dictionary = {
	"sword": 0,
	"dagger": 1,
	"axe": 2,
	"bow": 3,
	"spear": 5,
	"mace": 7,
	"staff": 10
}


static func get_weapon(weapon_id: String) -> Dictionary:
	return WEAPONS.get(weapon_id, {})


static func get_weapon_ids() -> Array:
	return WEAPONS.keys()


static func get_base_value(weapon_id: String) -> float:
	return BASE_VALUES.get(weapon_id, 1.0)


static func get_unlock_requirement(weapon_id: String) -> int:
	return UNLOCK_ASCENSIONS.get(weapon_id, 999)
