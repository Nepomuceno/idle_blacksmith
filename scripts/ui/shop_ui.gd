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
	var visible_upgrades = ascension_manager.get_visible_soul_upgrades()
	
	for upgrade_id in visible_upgrades:
		var data = UpgradeData.get_soul_upgrade(upgrade_id)
		var level = game_state.ascension_upgrades.get(upgrade_id, 0)
		var is_unlocked = ascension_manager.is_soul_upgrade_unlocked(upgrade_id)
		var is_maxed = ascension_manager.is_soul_upgrade_maxed(upgrade_id)
		var cost = ascension_manager.get_soul_upgrade_cost(upgrade_id)
		var can_afford = ascension_manager.can_afford_soul_upgrade(upgrade_id)
		var required_ascensions = data.get("unlock_ascensions", 0)
		var is_ultimate = data.get("is_ultimate", false)
		
		var btn = Button.new()
		btn.name = "soul_" + upgrade_id
		btn.custom_minimum_size = Vector2(0, 70)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		if is_maxed:
			btn.text = "%s - OWNED\n%s" % [data.get("name", ""), data.get("desc", "")]
			btn.disabled = true
			btn.modulate = Color(0.5, 1.0, 0.5)
		elif not is_unlocked:
			btn.text = "%s - LOCKED\n%s\nRequires %d Ascensions" % [data.get("name", ""), data.get("desc", ""), required_ascensions]
			btn.disabled = true
			btn.modulate = Color(0.4, 0.4, 0.4)
		else:
			btn.text = "%s (Lv %d)\n%s\nCost: %d souls" % [data.get("name", ""), level, data.get("desc", ""), cost]
			btn.disabled = not can_afford
			btn.modulate = Color(1, 1, 1) if can_afford else Color(0.5, 0.5, 0.5)
		
		# Special styling for ultimate upgrade
		if is_ultimate:
			btn.add_theme_color_override("font_color", ThemeColors.GOLD_TEXT)
		
		btn.add_theme_font_size_override("font_size", 14)
		btn.pressed.connect(_on_soul_upgrade_pressed.bind(upgrade_id))
		shop_list.add_child(btn)
	
	# Add automation toggle if auto-buy is unlocked
	if game_state.ascension_upgrades.get("auto_buy", 0) >= 1:
		_add_spacer(10)
		_create_auto_buy_toggle()
	
	# Add auto-ascend settings if unlocked
	if game_state.ascension_upgrades.get("auto_ascend", 0) >= 1:
		_add_spacer(10)
		_create_auto_ascend_settings()


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


func _create_auto_buy_toggle() -> void:
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var label = Label.new()
	label.text = "Auto-Buy Upgrades: "
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", ThemeColors.STEEL_LIGHT)
	hbox.add_child(label)
	
	var toggle = CheckButton.new()
	toggle.button_pressed = game_state.auto_buy_enabled
	toggle.toggled.connect(_on_auto_buy_toggled)
	hbox.add_child(toggle)
	
	shop_list.add_child(hbox)


func _create_auto_ascend_settings() -> void:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	
	# Toggle
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var label = Label.new()
	label.text = "Auto-Ascend: "
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", ThemeColors.STEEL_LIGHT)
	hbox.add_child(label)
	
	var toggle = CheckButton.new()
	toggle.button_pressed = game_state.auto_ascend_enabled
	toggle.toggled.connect(_on_auto_ascend_toggled)
	hbox.add_child(toggle)
	
	vbox.add_child(hbox)
	
	# Threshold slider
	var threshold_hbox = HBoxContainer.new()
	threshold_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var last_souls = game_state.last_ascension_souls
	var threshold_text = ""
	if last_souls > 0:
		var target = int(last_souls * game_state.auto_ascend_threshold)
		threshold_text = "Threshold: %.1fx last (%d souls)" % [game_state.auto_ascend_threshold, target]
	else:
		threshold_text = "Threshold: %.1fx last ascension" % game_state.auto_ascend_threshold
	
	var threshold_label = Label.new()
	threshold_label.text = threshold_text
	threshold_label.add_theme_font_size_override("font_size", 12)
	threshold_label.add_theme_color_override("font_color", ThemeColors.STEEL_LIGHT)
	threshold_label.name = "ThresholdLabel"
	threshold_hbox.add_child(threshold_label)
	
	vbox.add_child(threshold_hbox)
	
	var slider = HSlider.new()
	slider.min_value = 1.0
	slider.max_value = 10.0
	slider.step = 0.5
	slider.value = game_state.auto_ascend_threshold
	slider.custom_minimum_size = Vector2(200, 20)
	slider.value_changed.connect(_on_auto_ascend_threshold_changed.bind(threshold_label))
	vbox.add_child(slider)
	
	shop_list.add_child(vbox)


func _on_auto_buy_toggled(enabled: bool) -> void:
	game_state.auto_buy_enabled = enabled


func _on_auto_ascend_toggled(enabled: bool) -> void:
	game_state.auto_ascend_enabled = enabled


func _on_auto_ascend_threshold_changed(value: float, label: Label) -> void:
	game_state.auto_ascend_threshold = value
	var last_souls = game_state.last_ascension_souls
	if last_souls > 0:
		var target = int(last_souls * value)
		label.text = "Threshold: %.1fx last (%d souls)" % [value, target]
	else:
		label.text = "Threshold: %.1fx last ascension" % value
