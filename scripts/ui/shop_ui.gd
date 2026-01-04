class_name ShopUI
extends Control
## UI component for the Soul Shop tab

const UpgradeData = preload("res://scripts/data/upgrade_data.gd")
const WeaponData = preload("res://scripts/data/weapon_data.gd")
const GameState = preload("res://scripts/data/game_state.gd")

signal soul_upgrade_purchased(upgrade_id: String)
signal weapon_upgrade_purchased(weapon_id: String)
signal reset_requested

var game_state
var ascension_manager
var forge_manager
var shop_list: VBoxContainer


func setup(state, asc_manager, frg_manager) -> void:
	game_state = state
	ascension_manager = asc_manager
	forge_manager = frg_manager


func refresh() -> void:
	if shop_list == null:
		return
	
	for child in shop_list.get_children():
		child.queue_free()
	
	# Soul count header
	var souls_label = Label.new()
	souls_label.text = "Ancient Souls: %s" % GameState.format_souls(game_state.ancient_souls)
	souls_label.add_theme_color_override("font_color", ThemeColors.COLOR_SOULS)
	souls_label.add_theme_font_size_override("font_size", 22)
	souls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_list.add_child(souls_label)
	
	var info_label = Label.new()
	info_label.text = "Permanent bonuses that persist after Ascension"
	info_label.add_theme_color_override("font_color", ThemeColors.STEEL_LIGHT)
	info_label.add_theme_font_size_override("font_size", 12)
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	shop_list.add_child(info_label)
	
	_add_spacer(10)
	
	# Soul upgrades section
	_add_section_header("SOUL UPGRADES", ThemeColors.COLOR_SOULS)
	_create_soul_upgrades()
	
	_add_spacer(15)
	
	# Weapon upgrades section
	_add_section_header("WEAPON UPGRADES", ThemeColors.GOLD_TEXT)
	_create_weapon_upgrades()
	
	_add_spacer(20)
	
	# Reset button
	var reset_btn = Button.new()
	reset_btn.text = "RESET ALL PROGRESS"
	reset_btn.custom_minimum_size = Vector2(0, 50)
	reset_btn.add_theme_font_size_override("font_size", 14)
	reset_btn.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
	reset_btn.pressed.connect(_on_reset_pressed)
	shop_list.add_child(reset_btn)
	
	_add_spacer(30)
	
	# Credits
	var credit_label = Label.new()
	credit_label.text = "Developed by Gabriel Nepomuceno"
	credit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credit_label.add_theme_font_size_override("font_size", 12)
	credit_label.add_theme_color_override("font_color", ThemeColors.STEEL_DARK)
	shop_list.add_child(credit_label)


func _add_spacer(height: int) -> void:
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	shop_list.add_child(spacer)


func _add_section_header(text: String, color: Color) -> void:
	var header = Label.new()
	header.text = text
	header.add_theme_color_override("font_color", color)
	header.add_theme_font_size_override("font_size", 16)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_list.add_child(header)


func _create_soul_upgrades() -> void:
	for upgrade_id in UpgradeData.get_soul_upgrade_ids():
		var data = UpgradeData.get_soul_upgrade(upgrade_id)
		var level = game_state.ascension_upgrades.get(upgrade_id, 0)
		var cost = ascension_manager.get_soul_upgrade_cost(upgrade_id)
		var can_afford = ascension_manager.can_afford_soul_upgrade(upgrade_id)
		
		var btn = Button.new()
		btn.name = "soul_" + upgrade_id
		btn.custom_minimum_size = Vector2(0, 70)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.text = "%s (Lv %d)\n%s\nCost: %d souls" % [data.get("name", ""), level, data.get("desc", ""), cost]
		btn.add_theme_font_size_override("font_size", 14)
		btn.disabled = not can_afford
		btn.modulate = Color(1, 1, 1) if can_afford else Color(0.5, 0.5, 0.5)
		btn.pressed.connect(_on_soul_upgrade_pressed.bind(upgrade_id))
		shop_list.add_child(btn)


func _create_weapon_upgrades() -> void:
	var unlocked_weapons = forge_manager.get_unlocked_weapons()
	
	for weapon_id in WeaponData.get_weapon_ids():
		var weapon = WeaponData.get_weapon(weapon_id)
		var is_unlocked = weapon_id in unlocked_weapons
		var level = game_state.weapon_upgrade_levels.get(weapon_id, 0)
		var cost = ascension_manager.get_weapon_upgrade_cost(weapon_id)
		var can_afford = ascension_manager.can_afford_weapon_upgrade(weapon_id, forge_manager)
		
		var btn = Button.new()
		btn.name = "weapon_" + weapon_id
		btn.custom_minimum_size = Vector2(0, 60)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		if is_unlocked:
			var mult = game_state.weapon_multipliers.get(weapon_id, 1.0)
			btn.text = "%s (Lv %d) - x%.2f bonus\n+25%% value | Cost: %d souls" % [weapon.get("name", ""), level, mult, cost]
			btn.disabled = not can_afford
			btn.modulate = Color(1, 1, 1) if can_afford else Color(0.5, 0.5, 0.5)
		else:
			var required = WeaponData.get_unlock_requirement(weapon_id)
			btn.text = "%s - LOCKED\nUnlocks at Ascension %d" % [weapon.get("name", ""), required]
			btn.disabled = true
			btn.modulate = Color(0.4, 0.4, 0.4)
		
		btn.add_theme_font_size_override("font_size", 13)
		btn.pressed.connect(_on_weapon_upgrade_pressed.bind(weapon_id))
		shop_list.add_child(btn)


func _on_soul_upgrade_pressed(upgrade_id: String) -> void:
	if ascension_manager.purchase_soul_upgrade(upgrade_id):
		soul_upgrade_purchased.emit(upgrade_id)
		refresh()


func _on_weapon_upgrade_pressed(weapon_id: String) -> void:
	if ascension_manager.purchase_weapon_upgrade(weapon_id, forge_manager):
		weapon_upgrade_purchased.emit(weapon_id)
		refresh()


func _on_reset_pressed() -> void:
	reset_requested.emit()
