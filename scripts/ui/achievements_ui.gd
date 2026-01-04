class_name AchievementsUI
extends Control
## UI component for the Achievements tab

const AchievementData = preload("res://scripts/data/achievement_data.gd")
const GameState = preload("res://scripts/data/game_state.gd")

signal rewards_claimed(amount: float)

var game_state
var achievement_manager
var achieve_list: VBoxContainer


func setup(state, manager) -> void:
	game_state = state
	achievement_manager = manager


func refresh() -> void:
	if achieve_list == null:
		return
	
	for child in achieve_list.get_children():
		child.queue_free()
	
	# Progress header
	var progress = achievement_manager.get_progress()
	var progress_label = Label.new()
	progress_label.text = "Achievements: %d / %d (%.0f%%)" % [progress["unlocked"], progress["total"], progress["percent"]]
	progress_label.add_theme_color_override("font_color", ThemeColors.GOLD_TEXT)
	progress_label.add_theme_font_size_override("font_size", 18)
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	achieve_list.add_child(progress_label)
	
	# Claim rewards button
	if game_state.pending_achievement_rewards > 0:
		var claim_btn = Button.new()
		claim_btn.text = "Claim Rewards: +%s Gold" % GameState.format_number(game_state.pending_achievement_rewards)
		claim_btn.custom_minimum_size = Vector2(0, 50)
		claim_btn.add_theme_font_size_override("font_size", 16)
		claim_btn.add_theme_color_override("font_color", ThemeColors.GOLD_BRIGHT)
		claim_btn.pressed.connect(_on_claim_pressed)
		achieve_list.add_child(claim_btn)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	achieve_list.add_child(spacer)
	
	# Unlocked achievements
	var unlocked = achievement_manager.get_unlocked()
	var locked = achievement_manager.get_locked()
	
	if unlocked.size() > 0:
		var header = Label.new()
		header.text = "UNLOCKED"
		header.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
		header.add_theme_font_size_override("font_size", 14)
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		achieve_list.add_child(header)
		
		for achievement_id in unlocked:
			var panel = _create_achievement_panel(achievement_id, true)
			achieve_list.add_child(panel)
	
	if locked.size() > 0:
		var header = Label.new()
		header.text = "LOCKED"
		header.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		header.add_theme_font_size_override("font_size", 14)
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		achieve_list.add_child(header)
		
		for achievement_id in locked:
			var panel = _create_achievement_panel(achievement_id, false)
			achieve_list.add_child(panel)


func _on_claim_pressed() -> void:
	var amount = achievement_manager.claim_rewards()
	if amount > 0:
		rewards_claimed.emit(amount)
		refresh()


func _create_achievement_panel(achievement_id: String, is_unlocked: bool) -> PanelContainer:
	var data = AchievementData.get_achievement(achievement_id)
	
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 60)
	
	var style = StyleBoxFlat.new()
	if is_unlocked:
		style.bg_color = Color(0.12, 0.16, 0.12, 0.9)
		style.border_color = Color(0.3, 0.8, 0.3, 0.8)
	else:
		style.bg_color = ThemeColors.BG_PANEL.darkened(0.2)
		style.border_color = ThemeColors.STEEL_DARK
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	
	# Icon
	var icon_panel = _create_icon_panel(data, is_unlocked)
	hbox.add_child(icon_panel)
	
	# Content
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var name_label = Label.new()
	name_label.text = data.get("name", achievement_id)
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", ThemeColors.GOLD_BRIGHT if is_unlocked else ThemeColors.STEEL_LIGHT)
	vbox.add_child(name_label)
	
	var desc_label = Label.new()
	desc_label.text = data.get("desc", "")
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", ThemeColors.STEEL_LIGHT if is_unlocked else ThemeColors.STEEL_DARK)
	vbox.add_child(desc_label)
	
	var reward = data.get("reward", 0)
	if reward > 0:
		var reward_label = Label.new()
		reward_label.text = "Reward: +%s gold" % GameState.format_number(reward)
		reward_label.add_theme_font_size_override("font_size", 11)
		reward_label.add_theme_color_override("font_color", ThemeColors.GOLD_TEXT if is_unlocked else ThemeColors.STEEL_DARK)
		vbox.add_child(reward_label)
	
	hbox.add_child(vbox)
	panel.add_child(hbox)
	
	return panel


func _create_icon_panel(data: Dictionary, is_unlocked: bool) -> PanelContainer:
	var icon_panel = PanelContainer.new()
	icon_panel.custom_minimum_size = Vector2(44, 44)
	
	var icon_style = StyleBoxFlat.new()
	icon_style.bg_color = ThemeColors.IRON_ANVIL if is_unlocked else ThemeColors.BG_MAIN
	icon_style.set_corner_radius_all(6)
	icon_panel.add_theme_stylebox_override("panel", icon_style)
	
	var icon_path = "res://assets/icons/" + data.get("icon", "")
	if ResourceLoader.exists(icon_path):
		var tex_rect = TextureRect.new()
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.texture = load(icon_path)
		if not is_unlocked:
			tex_rect.modulate = Color(0.4, 0.4, 0.4)
		icon_panel.add_child(tex_rect)
	else:
		var star = Label.new()
		star.text = "*" if is_unlocked else "?"
		star.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		star.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		star.add_theme_font_size_override("font_size", 24)
		star.add_theme_color_override("font_color", ThemeColors.GOLD_TEXT if is_unlocked else ThemeColors.STEEL_DARK)
		icon_panel.add_child(star)
	
	return icon_panel
