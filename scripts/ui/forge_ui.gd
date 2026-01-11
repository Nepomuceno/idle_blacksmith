class_name ForgeUI
extends Control
## UI component for the Forge tab

const WeaponData = preload("res://scripts/data/weapon_data.gd")
const GameState = preload("res://scripts/data/game_state.gd")

signal forge_requested
signal weapon_selected(weapon_id: String)
signal ascend_requested

var game_state
var forge_manager
var texture_cache: Dictionary = {}
var weapon_buttons: Dictionary = {}

# Node references (set by parent)
var forge_button: Button
var ascend_button: Button
var weapon_grid: HBoxContainer
var main_weapon_icon: TextureRect
var main_weapon_letter: Label
var weapon_name_label: Label
var value_label: Label
var streak_label: Label
var last_forged_label: Label
var ascension_progress: ProgressBar


func setup(state, manager) -> void:
	game_state = state
	forge_manager = manager
	_preload_textures()


func _preload_textures() -> void:
	var icons_path = "res://assets/icons/"
	for weapon_id in WeaponData.get_weapon_ids():
		var weapon = WeaponData.get_weapon(weapon_id)
		var path = icons_path + weapon.get("icon", "")
		if ResourceLoader.exists(path):
			texture_cache[weapon["icon"]] = load(path)


func connect_buttons() -> void:
	if forge_button != null:
		forge_button.pressed.connect(_on_forge_pressed)
		forge_button.pivot_offset = forge_button.size / 2
	if ascend_button != null:
		ascend_button.pressed.connect(_on_ascend_pressed)
		ascend_button.visible = false


func _on_forge_pressed() -> void:
	forge_requested.emit()


func _on_ascend_pressed() -> void:
	ascend_requested.emit()


func create_weapon_grid() -> void:
	if weapon_grid == null:
		return
	
	for child in weapon_grid.get_children():
		child.queue_free()
	
	weapon_buttons.clear()
	var button_group = ButtonGroup.new()
	var btn_size = Vector2(50, 60)
	var icon_size = Vector2(32, 32)
	
	var unlocked_weapons = forge_manager.get_unlocked_weapons()
	
	for weapon_id in WeaponData.get_weapon_ids():
		var weapon = WeaponData.get_weapon(weapon_id)
		var is_unlocked = weapon_id in unlocked_weapons
		
		var btn = _create_weapon_button(weapon_id, weapon, is_unlocked, button_group, btn_size, icon_size)
		weapon_grid.add_child(btn)
		weapon_buttons[weapon_id] = btn
		
		if is_unlocked:
			btn.pressed.connect(_on_weapon_pressed.bind(weapon_id))
		
		if weapon_id == game_state.selected_weapon:
			btn.button_pressed = true


func _create_weapon_button(weapon_id: String, weapon: Dictionary, is_unlocked: bool, 
		button_group: ButtonGroup, btn_size: Vector2, icon_size: Vector2) -> Button:
	var btn = Button.new()
	btn.name = weapon_id
	btn.custom_minimum_size = btn_size
	btn.toggle_mode = true
	btn.button_group = button_group
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.disabled = not is_unlocked
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 2)
	
	var icon_panel = _create_icon_panel(weapon, is_unlocked, icon_size)
	vbox.add_child(icon_panel)
	
	var name_label = Label.new()
	if is_unlocked:
		name_label.text = weapon.get("name", weapon_id)
		name_label.add_theme_color_override("font_color", weapon.get("color", Color.WHITE))
	else:
		var required = WeaponData.get_unlock_requirement(weapon_id)
		name_label.text = "Asc %d" % required
		name_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 9)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_label)
	
	btn.add_child(vbox)
	return btn


func _create_icon_panel(weapon: Dictionary, is_unlocked: bool, icon_size: Vector2) -> PanelContainer:
	var icon_panel = PanelContainer.new()
	icon_panel.custom_minimum_size = icon_size
	icon_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var icon_style = StyleBoxFlat.new()
	var color = weapon.get("color", Color.WHITE)
	if is_unlocked:
		icon_style.bg_color = color * 0.3
		icon_style.border_color = color
	else:
		icon_style.bg_color = Color(0.1, 0.1, 0.1)
		icon_style.border_color = Color(0.3, 0.3, 0.3)
	icon_style.set_border_width_all(2)
	icon_style.set_corner_radius_all(6)
	icon_panel.add_theme_stylebox_override("panel", icon_style)
	
	var icon_name = weapon.get("icon", "")
	if texture_cache.has(icon_name):
		var icon_tex = TextureRect.new()
		icon_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_tex.texture = texture_cache[icon_name]
		if not is_unlocked:
			icon_tex.modulate = Color(0.3, 0.3, 0.3)
		icon_panel.add_child(icon_tex)
	else:
		var letter = Label.new()
		letter.text = weapon.get("symbol", "?") if is_unlocked else "?"
		letter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		letter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		letter.add_theme_font_size_override("font_size", 18)
		letter.add_theme_color_override("font_color", color if is_unlocked else Color(0.3, 0.3, 0.3))
		letter.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon_panel.add_child(letter)
	
	return icon_panel


func _on_weapon_pressed(weapon_id: String) -> void:
	weapon_selected.emit(weapon_id)


func update_display() -> void:
	_update_weapon_display()
	_update_weapon_buttons()
	_update_ascension_progress()


func _update_weapon_display() -> void:
	var weapon_id = game_state.selected_weapon
	var weapon = WeaponData.get_weapon(weapon_id)
	
	var icon_name = weapon.get("icon", "")
	if texture_cache.has(icon_name) and main_weapon_icon:
		main_weapon_icon.texture = texture_cache[icon_name]
		main_weapon_letter.visible = false
		main_weapon_icon.visible = true
	elif main_weapon_letter:
		main_weapon_letter.text = weapon.get("symbol", "?")
		main_weapon_letter.add_theme_color_override("font_color", weapon.get("color", Color.WHITE))
		main_weapon_letter.visible = true
		if main_weapon_icon:
			main_weapon_icon.visible = false
	
	if weapon_name_label:
		weapon_name_label.text = weapon.get("name", weapon_id)
		weapon_name_label.add_theme_color_override("font_color", weapon.get("color", Color.WHITE))
	
	if value_label:
		var total = forge_manager.get_weapon_value(weapon_id)
		var weapon_mult = game_state.weapon_multipliers.get(weapon_id, 1.0)
		var mastery_level = game_state.get_weapon_mastery_level(weapon_id)
		var mastery_bonus = game_state.get_weapon_mastery_bonus(weapon_id)
		
		var value_parts = ["Value: %s" % GameState.format_number(total)]
		
		if weapon_mult > 1.0:
			value_parts.append("Soul: x%.2f" % weapon_mult)
		
		if mastery_level > 0:
			value_parts.append("Mastery Lv%d (+%d%%)" % [mastery_level, int(mastery_bonus * 100)])
		
		value_label.text = " | ".join(value_parts)
	
	if streak_label:
		var forged_count = game_state.items_forged.get(weapon_id, 0)
		var streak_text = "Forged: %d" % forged_count
		
		# Show current streak bonus if active
		if game_state.forge_streak > 0:
			var streak_bonus = game_state.get_streak_bonus()
			streak_text += " | Streak: %dx (+%d%%)" % [game_state.forge_streak, int(streak_bonus * 100)]
		
		# Show crit chance
		var crit_chance = game_state.get_effective_crit_chance()
		if crit_chance > 0.05:  # Show if above base
			streak_text += " | Crit: %d%%" % int(crit_chance * 100)
		
		streak_label.text = streak_text
		streak_label.visible = true


func _update_weapon_buttons() -> void:
	var unlocked_weapons = forge_manager.get_unlocked_weapons()
	for weapon_id in weapon_buttons:
		var btn = weapon_buttons[weapon_id]
		var is_selected = weapon_id == game_state.selected_weapon
		var is_unlocked = weapon_id in unlocked_weapons
		
		if is_selected and is_unlocked:
			btn.modulate = Color(1.3, 1.2, 0.8)
		elif is_unlocked:
			btn.modulate = Color(0.7, 0.7, 0.7)
		else:
			btn.modulate = Color(0.5, 0.5, 0.5)


const ASCENSION_THRESHOLD: float = 100000.0

func _update_ascension_progress() -> void:
	var threshold = ASCENSION_THRESHOLD
	var progress = minf(game_state.total_gold_earned / threshold, 1.0)
	
	if ascension_progress:
		ascension_progress.value = progress * 100
	
	if ascend_button:
		var can_ascend = game_state.total_gold_earned >= threshold
		if can_ascend:
			ascend_button.visible = true
			var souls = int(sqrt(game_state.total_gold_earned / 10000.0))
			ascend_button.text = "ASCEND +%d" % souls
		else:
			ascend_button.visible = false


func show_forge_result(result: Dictionary) -> void:
	if last_forged_label:
		var tier_name = result.get("tier_name", "Common")
		var tier_color = result.get("tier_color", Color.WHITE)
		var is_crit = result.get("is_crit", false)
		
		if is_crit:
			last_forged_label.text = "CRIT! %s" % tier_name
			last_forged_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))
		else:
			last_forged_label.text = "Last: %s" % tier_name
			last_forged_label.add_theme_color_override("font_color", tier_color)
