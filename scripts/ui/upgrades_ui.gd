class_name UpgradesUI
extends Control
## UI component for the Upgrades tab

const UpgradeData = preload("res://scripts/data/upgrade_data.gd")
const GameState = preload("res://scripts/data/game_state.gd")

signal upgrade_purchased(upgrade_id: String)

var game_state
var upgrade_manager
var upgrades_list: VBoxContainer


func setup(state, manager) -> void:
	game_state = state
	upgrade_manager = manager


func refresh() -> void:
	if upgrades_list == null:
		return
	
	for child in upgrades_list.get_children():
		child.queue_free()
	
	_create_stats_summary()
	
	var visible_upgrades = upgrade_manager.get_visible_upgrades()
	for upgrade_id in visible_upgrades:
		var card = _create_upgrade_card(upgrade_id)
		upgrades_list.add_child(card)


func _create_stats_summary() -> void:
	var stats_panel = PanelContainer.new()
	stats_panel.custom_minimum_size = Vector2(0, 48)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.055, 0.08, 0.95)
	style.border_color = Color(0.45, 0.5, 0.55, 0.6)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.shadow_color = Color(0, 0, 0, 0.15)
	style.shadow_size = 2
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	stats_panel.add_theme_stylebox_override("panel", style)
	
	var stats_hbox = HBoxContainer.new()
	stats_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	stats_hbox.add_theme_constant_override("separation", 24)
	
	# Click power stat
	var click_stat = _create_stat_display(
		"+%.1f" % game_state.click_power,
		"/click",
		UpgradeData.get_effect_color("click_power")
	)
	stats_hbox.add_child(click_stat)
	
	# Passive income stat
	var passive_stat = _create_stat_display(
		"+%.1f" % game_state.passive_income,
		"/sec",
		UpgradeData.get_effect_color("passive_income")
	)
	stats_hbox.add_child(passive_stat)
	
	# Auto-forge stat
	var auto_stat = _create_stat_display(
		"%.1f" % game_state.auto_forge_rate,
		" forge/s",
		UpgradeData.get_effect_color("auto_forge")
	)
	stats_hbox.add_child(auto_stat)
	
	# Multiplier diminishing indicator (only show if player has purchased multipliers)
	if game_state.total_multipliers_purchased > 0:
		var mult_stat = _create_stat_display(
			"%d" % game_state.total_multipliers_purchased,
			" mults",
			UpgradeData.get_effect_color("multiplier")
		)
		stats_hbox.add_child(mult_stat)
	
	stats_panel.add_child(stats_hbox)
	upgrades_list.add_child(stats_panel)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	upgrades_list.add_child(spacer)


func _create_stat_display(value: String, suffix: String, color: Color) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", 2)
	
	var value_label = Label.new()
	value_label.text = value
	value_label.add_theme_font_size_override("font_size", 17)
	value_label.add_theme_color_override("font_color", color)
	value_label.add_theme_color_override("font_outline_color", color * 0.25)
	value_label.add_theme_constant_override("outline_size", 1)
	container.add_child(value_label)
	
	var suffix_label = Label.new()
	suffix_label.text = suffix
	suffix_label.add_theme_font_size_override("font_size", 12)
	suffix_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
	container.add_child(suffix_label)
	
	return container


func _create_upgrade_card(upgrade_id: String) -> PanelContainer:
	var data = UpgradeData.get_upgrade(upgrade_id)
	var cost = upgrade_manager.get_cost(upgrade_id)
	var level = game_state.upgrades.get(upgrade_id, 0)
	var can_afford = game_state.gold >= cost
	var is_maxed = upgrade_manager.is_maxed(upgrade_id)
	var effect_type = data.get("effect_type", "click_power")
	var effect_color = UpgradeData.get_effect_color(effect_type)
	var afford_progress = minf(game_state.gold / cost, 1.0) if not is_maxed else 1.0
	
	var card = PanelContainer.new()
	card.name = upgrade_id
	card.custom_minimum_size = Vector2(0, 72)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var card_style = StyleBoxFlat.new()
	if is_maxed:
		card_style.bg_color = Color(0.08, 0.12, 0.08, 0.95)
		card_style.border_color = Color(0.35, 0.65, 0.35, 0.9)
	elif can_afford:
		card_style.bg_color = Color(0.06, 0.055, 0.08, 0.95)
		card_style.border_color = effect_color * 0.85
	else:
		card_style.bg_color = Color(0.04, 0.04, 0.055, 0.9)
		card_style.border_color = Color(0.3, 0.3, 0.35, 0.5)
	
	card_style.border_width_left = 5
	card_style.border_width_right = 2
	card_style.border_width_top = 2
	card_style.border_width_bottom = 2
	card_style.corner_radius_top_left = 10
	card_style.corner_radius_top_right = 10
	card_style.corner_radius_bottom_left = 10
	card_style.corner_radius_bottom_right = 10
	card_style.content_margin_left = 12
	card_style.content_margin_right = 10
	card_style.content_margin_top = 8
	card_style.content_margin_bottom = 8
	
	# Add subtle glow for affordable
	if can_afford and not is_maxed:
		card_style.shadow_color = effect_color * 0.3
		card_style.shadow_size = 3
	
	card.add_theme_stylebox_override("panel", card_style)
	
	var main_hbox = HBoxContainer.new()
	main_hbox.add_theme_constant_override("separation", 12)
	
	# Icon
	var icon_container = _create_icon_container(data, effect_color, is_maxed, can_afford)
	main_hbox.add_child(icon_container)
	
	# Content
	var content_vbox = _create_content_vbox(data, upgrade_id, level, cost, is_maxed, can_afford, effect_type, effect_color, afford_progress)
	main_hbox.add_child(content_vbox)
	
	card.add_child(main_hbox)
	
	if not is_maxed:
		card.gui_input.connect(_on_card_input.bind(upgrade_id))
		card.mouse_entered.connect(_on_card_hover.bind(card, upgrade_id, true))
		card.mouse_exited.connect(_on_card_hover.bind(card, upgrade_id, false))
	
	return card


func _create_icon_container(data: Dictionary, effect_color: Color, is_maxed: bool, can_afford: bool) -> PanelContainer:
	var icon_container = PanelContainer.new()
	icon_container.custom_minimum_size = Vector2(44, 44)
	
	var icon_style = StyleBoxFlat.new()
	if is_maxed:
		icon_style.bg_color = Color(0.15, 0.25, 0.15, 0.9)
		icon_style.border_color = Color(0.4, 0.7, 0.4, 0.7)
	elif can_afford:
		icon_style.bg_color = effect_color * 0.2
		icon_style.border_color = effect_color * 0.6
	else:
		icon_style.bg_color = Color(0.08, 0.08, 0.1, 0.9)
		icon_style.border_color = Color(0.25, 0.25, 0.3, 0.5)
	
	icon_style.set_border_width_all(2)
	icon_style.set_corner_radius_all(8)
	icon_container.add_theme_stylebox_override("panel", icon_style)
	
	var icon_path = "res://assets/icons/" + data.get("icon", "")
	if ResourceLoader.exists(icon_path):
		var tex_rect = TextureRect.new()
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.texture = load(icon_path)
		if not can_afford and not is_maxed:
			tex_rect.modulate = Color(0.45, 0.45, 0.45)
		icon_container.add_child(tex_rect)
	
	return icon_container


func _create_content_vbox(data: Dictionary, upgrade_id: String, level: int, cost: float, 
		is_maxed: bool, can_afford: bool, effect_type: String, effect_color: Color, 
		afford_progress: float) -> VBoxContainer:
	var content_vbox = VBoxContainer.new()
	content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_vbox.add_theme_constant_override("separation", 3)
	
	# Header row
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 8)
	
	var name_label = Label.new()
	name_label.text = data.get("name", upgrade_id)
	name_label.add_theme_font_size_override("font_size", 15)
	var name_color = Color(0.4, 0.8, 0.4) if is_maxed else (Color.WHITE if can_afford else Color(0.6, 0.6, 0.6))
	name_label.add_theme_color_override("font_color", name_color)
	header_hbox.add_child(name_label)
	
	if level > 0:
		var level_label = Label.new()
		level_label.text = "Lv.%d" % level
		level_label.add_theme_font_size_override("font_size", 12)
		level_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
		header_hbox.add_child(level_label)
	
	# Effect type badge
	var badge = Label.new()
	badge.text = UpgradeData.get_effect_label(effect_type)
	badge.add_theme_font_size_override("font_size", 10)
	badge.add_theme_color_override("font_color", effect_color)
	header_hbox.add_child(badge)
	
	content_vbox.add_child(header_hbox)
	
	# Description
	var desc_label = Label.new()
	desc_label.text = data.get("desc", "")
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6) if not can_afford and not is_maxed else Color(0.7, 0.7, 0.75))
	content_vbox.add_child(desc_label)
	
	# Cost row
	if is_maxed:
		var maxed_label = Label.new()
		maxed_label.text = "MAXED"
		maxed_label.add_theme_font_size_override("font_size", 13)
		maxed_label.add_theme_color_override("font_color", Color(0.4, 0.8, 0.4))
		content_vbox.add_child(maxed_label)
	else:
		var cost_hbox = HBoxContainer.new()
		cost_hbox.add_theme_constant_override("separation", 10)
		
		var cost_label = Label.new()
		cost_label.text = "Cost: %s" % GameState.format_number(cost)
		cost_label.add_theme_font_size_override("font_size", 12)
		cost_label.add_theme_color_override("font_color", ThemeColors.GOLD_TEXT if can_afford else ThemeColors.STEEL_DARK)
		cost_hbox.add_child(cost_label)
		
		# Next effect preview
		var next_effect = upgrade_manager.get_effect(upgrade_id)
		var next_label = Label.new()
		
		if effect_type == "multiplier":
			# Show effective multiplier after diminishing returns
			var effective_mult = upgrade_manager.get_preview_multiplier(upgrade_id)
			next_label.text = "Effective: x%.2f" % effective_mult
			if game_state.total_multipliers_purchased > 0:
				next_label.text += " (reduced)"
		else:
			next_label.text = "Next: +%.1f" % next_effect
		
		next_label.add_theme_font_size_override("font_size", 11)
		next_label.add_theme_color_override("font_color", effect_color * 0.7)
		cost_hbox.add_child(next_label)
		
		content_vbox.add_child(cost_hbox)
		
		# Progress bar if close to affording
		if afford_progress >= 0.5 and afford_progress < 1.0:
			var progress_bar = ProgressBar.new()
			progress_bar.custom_minimum_size = Vector2(0, 4)
			progress_bar.value = afford_progress * 100
			progress_bar.show_percentage = false
			content_vbox.add_child(progress_bar)
	
	return content_vbox


func _on_card_input(event: InputEvent, upgrade_id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cost = upgrade_manager.get_cost(upgrade_id)
		if game_state.gold >= cost:
			if upgrade_manager.purchase(upgrade_id):
				upgrade_purchased.emit(upgrade_id)
				refresh()


func _on_card_hover(card: PanelContainer, upgrade_id: String, hovering: bool) -> void:
	var cost = upgrade_manager.get_cost(upgrade_id)
	var can_afford = game_state.gold >= cost
	if hovering and can_afford:
		card.modulate = Color(1.1, 1.1, 1.1)
	else:
		card.modulate = Color.WHITE
