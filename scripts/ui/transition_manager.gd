## Transition Manager
## Handles smooth scene transitions, lore popups, and milestone celebrations
## Creates immersive narrative moments during gameplay

extends RefCounted
class_name TransitionManager

const LoreDataClass = preload("res://scripts/data/lore_data.gd")
const WeaponDataClass = preload("res://scripts/data/weapon_data.gd")

## Signals for transition events
signal transition_started
signal transition_complete
signal lore_popup_shown(popup_node: Control)
signal lore_popup_closed

## Colors matching game theme
const BG_COLOR := Color(0.02, 0.02, 0.04, 0.95)
const ACCENT_COLOR := Color(1, 0.7, 0.2, 1)
const TEXT_COLOR := Color(0.9, 0.85, 0.7, 1)
const SUBTITLE_COLOR := Color(0.6, 0.55, 0.5, 0.9)


## Create and show a lore popup with animation
static func show_lore_popup(parent: Control, title: String, text: String, quote: String = "", auto_close_delay: float = 0.0) -> Control:
	var overlay = ColorRect.new()
	overlay.name = "LorePopupOverlay"
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(overlay)
	
	# Fade in overlay
	var fade_tween = parent.create_tween()
	fade_tween.tween_property(overlay, "color:a", 0.85, 0.5)
	
	# Main panel
	var panel = PanelContainer.new()
	panel.name = "LorePanel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(380, 300)
	panel.pivot_offset = Vector2(190, 150)
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.8, 0.8)
	
	var style = StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.border_color = ACCENT_COLOR
	style.set_border_width_all(3)
	style.set_corner_radius_all(16)
	style.shadow_color = Color(1, 0.5, 0.1, 0.4)
	style.shadow_size = 15
	style.content_margin_left = 25
	style.content_margin_right = 25
	style.content_margin_top = 25
	style.content_margin_bottom = 25
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 15)
	
	# Decorative header
	var header_decor = Label.new()
	header_decor.text = "~ ~ ~"
	header_decor.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_decor.add_theme_font_size_override("font_size", 16)
	header_decor.add_theme_color_override("font_color", ACCENT_COLOR)
	vbox.add_child(header_decor)
	
	# Title
	var title_label = Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", ACCENT_COLOR)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(title_label)
	
	# Main text
	var text_label = Label.new()
	text_label.text = text
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.add_theme_font_size_override("font_size", 14)
	text_label.add_theme_color_override("font_color", TEXT_COLOR)
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	text_label.custom_minimum_size.x = 320
	vbox.add_child(text_label)
	
	# Quote if provided
	if quote != "":
		var quote_label = Label.new()
		quote_label.text = quote
		quote_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		quote_label.add_theme_font_size_override("font_size", 12)
		quote_label.add_theme_color_override("font_color", SUBTITLE_COLOR)
		quote_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		quote_label.custom_minimum_size.x = 300
		vbox.add_child(quote_label)
	
	# Footer decoration
	var footer_decor = Label.new()
	footer_decor.text = "~ ~ ~"
	footer_decor.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer_decor.add_theme_font_size_override("font_size", 16)
	footer_decor.add_theme_color_override("font_color", ACCENT_COLOR)
	vbox.add_child(footer_decor)
	
	# Continue button (unless auto-close)
	if auto_close_delay <= 0:
		var continue_btn = Button.new()
		continue_btn.text = "Continue"
		continue_btn.custom_minimum_size = Vector2(120, 45)
		continue_btn.add_theme_font_size_override("font_size", 16)
		continue_btn.pressed.connect(func():
			_close_popup(overlay, parent)
		)
		vbox.add_child(continue_btn)
	
	panel.add_child(vbox)
	overlay.add_child(panel)
	panel.position = (parent.get_viewport_rect().size - panel.custom_minimum_size) / 2
	
	# Animate panel appearing
	await parent.get_tree().create_timer(0.2).timeout
	var panel_tween = parent.create_tween()
	panel_tween.set_parallel(true)
	panel_tween.tween_property(panel, "modulate:a", 1.0, 0.4)
	panel_tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Auto-close if specified
	if auto_close_delay > 0:
		await parent.get_tree().create_timer(auto_close_delay).timeout
		_close_popup(overlay, parent)
	
	return overlay


static func _close_popup(overlay: Control, parent: Control) -> void:
	var close_tween = parent.create_tween()
	close_tween.tween_property(overlay, "modulate:a", 0.0, 0.3)
	close_tween.tween_callback(overlay.queue_free)


## Show a milestone celebration with particles and narrative
static func show_milestone_celebration(parent: Control, milestone_key: String) -> void:
	var milestone = LoreDataClass.get_milestone_narrative(milestone_key)
	if milestone.is_empty():
		return
	
	var title = milestone.get("title", "Milestone")
	var text = milestone.get("text", "")
	var quote = milestone.get("quote", "")
	
	# Spawn celebration particles first
	_spawn_celebration_particles(parent)
	
	# Show the lore popup
	await parent.get_tree().create_timer(0.3).timeout
	show_lore_popup(parent, title, text, quote)


## Show weapon unlock narrative with comparison to previous weapon
static func show_weapon_unlock(parent: Control, weapon_id: String) -> void:
	var lore = LoreDataClass.get_weapon_lore(weapon_id)
	if lore.is_empty():
		return
	
	var weapon = WeaponDataClass.get_weapon(weapon_id)
	var weapon_name = weapon.get("name", weapon_id.capitalize())
	var new_value = WeaponDataClass.get_base_value(weapon_id)
	
	# Find previous weapon for comparison
	var weapon_ids = WeaponDataClass.get_weapon_ids()
	var weapon_index = weapon_ids.find(weapon_id)
	var prev_weapon_id = weapon_ids[weapon_index - 1] if weapon_index > 0 else ""
	var prev_value = WeaponDataClass.get_base_value(prev_weapon_id) if prev_weapon_id != "" else 1.0
	var prev_name = WeaponDataClass.get_weapon(prev_weapon_id).get("name", "Sword") if prev_weapon_id != "" else "Sword"
	
	var improvement = ((new_value / prev_value) - 1.0) * 100.0
	
	var title = weapon_name + " Unlocked!"
	var text = lore.get("unlock_message", "A new weapon awaits your mastery.")
	
	# Add comparison info
	var comparison = "\n\n+%.0f%% base value vs %s" % [improvement, prev_name]
	text += comparison
	
	var quote = "\"" + lore.get("legend", "") + "\""
	
	_spawn_unlock_particles(parent)
	await parent.get_tree().create_timer(0.2).timeout
	show_lore_popup(parent, title, text, quote)


## Show ascension milestone narrative
static func show_ascension_milestone(parent: Control, ascension_count: int) -> void:
	var milestone = LoreDataClass.get_ascension_milestone(ascension_count)
	if milestone.is_empty():
		return
	
	var title = milestone.get("title", "Ascension")
	var text = milestone.get("message", "")
	
	_spawn_ascension_particles(parent)
	await parent.get_tree().create_timer(0.3).timeout
	show_lore_popup(parent, title, text)


## Show tier unlock celebration
static func show_tier_unlock(parent: Control, tier_key: String) -> void:
	var tier_lore = LoreDataClass.TIER_LORE.get(tier_key, {})
	if tier_lore.is_empty():
		return
	
	var title = tier_lore.get("name", "New Tier") + " Tier Unlocked!"
	var text = tier_lore.get("description", "")
	var quote = "\"" + tier_lore.get("flavor", "") + "\""
	
	_spawn_tier_unlock_particles(parent, tier_key)
	await parent.get_tree().create_timer(0.2).timeout
	show_lore_popup(parent, title, text, quote)


## Random lore tooltip during gameplay
static func show_random_lore_tooltip(parent: Control, position: Vector2) -> void:
	var tip = LoreDataClass.get_random_lore_snippet()
	
	var tooltip = PanelContainer.new()
	tooltip.name = "LoreTooltip"
	tooltip.position = position
	tooltip.modulate.a = 0.0
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.04, 0.08, 0.95)
	style.border_color = Color(0.6, 0.5, 0.3, 0.8)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	tooltip.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = tip
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color(0.8, 0.75, 0.6))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.custom_minimum_size.x = 250
	tooltip.add_child(label)
	
	parent.add_child(tooltip)
	
	# Animate in
	var tween = parent.create_tween()
	tween.tween_property(tooltip, "modulate:a", 1.0, 0.3)
	tween.tween_interval(4.0)
	tween.tween_property(tooltip, "modulate:a", 0.0, 0.5)
	tween.tween_callback(tooltip.queue_free)


## Spawn celebration particles
static func _spawn_celebration_particles(parent: Control) -> void:
	var center = parent.get_viewport_rect().size / 2
	var colors = [
		Color(1, 0.8, 0.2),
		Color(1, 0.6, 0.1),
		Color(1, 1, 0.5),
		Color(0.9, 0.7, 0.3),
	]
	
	for i in range(40):
		var particle = ColorRect.new()
		particle.size = Vector2(randf_range(4, 10), randf_range(4, 10))
		particle.color = colors[randi() % colors.size()]
		particle.position = center
		parent.add_child(particle)
		
		var angle = randf() * TAU
		var speed = randf_range(150, 400)
		var target = center + Vector2(cos(angle), sin(angle)) * speed
		
		var tween = parent.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", target, randf_range(0.8, 1.5)).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, randf_range(0.8, 1.5)).set_ease(Tween.EASE_IN)
		tween.tween_property(particle, "rotation", randf_range(-5, 5), 1.0)
		tween.set_parallel(false)
		tween.tween_callback(particle.queue_free)


static func _spawn_unlock_particles(parent: Control) -> void:
	var center = parent.get_viewport_rect().size / 2
	
	for i in range(25):
		var particle = ColorRect.new()
		particle.size = Vector2(6, 6)
		particle.color = Color(0.5, 0.8, 1.0) if randf() > 0.5 else Color(1, 1, 1)
		particle.position = center + Vector2(randf_range(-100, 100), randf_range(-50, 50))
		parent.add_child(particle)
		
		var target = particle.position + Vector2(0, -randf_range(80, 200))
		
		var tween = parent.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", target, 1.2).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, 1.2).set_ease(Tween.EASE_IN)
		tween.set_parallel(false)
		tween.tween_callback(particle.queue_free)


static func _spawn_ascension_particles(parent: Control) -> void:
	var center = parent.get_viewport_rect().size / 2
	var colors = [Color(0.8, 0.5, 1), Color(1, 0.8, 0.2), Color(1, 1, 1)]
	
	# Ring of particles
	for i in range(24):
		var angle = (i / 24.0) * TAU
		var particle = ColorRect.new()
		particle.size = Vector2(8, 8)
		particle.color = colors[i % colors.size()]
		particle.position = center + Vector2(cos(angle), sin(angle)) * 50
		parent.add_child(particle)
		
		var target = center + Vector2(cos(angle), sin(angle)) * 300
		
		var tween = parent.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", target, 1.0).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, 1.0).set_ease(Tween.EASE_IN)
		tween.tween_property(particle, "size", Vector2(2, 2), 1.0)
		tween.set_parallel(false)
		tween.tween_callback(particle.queue_free)


static func _spawn_tier_unlock_particles(parent: Control, tier_key: String) -> void:
	var center = parent.get_viewport_rect().size / 2
	var tier_colors = {
		"uncommon": Color(0.3, 0.8, 0.3),
		"rare": Color(0.3, 0.5, 1.0),
		"epic": Color(0.7, 0.3, 0.9),
		"legendary": Color(1.0, 0.6, 0.1),
	}
	var color = tier_colors.get(tier_key, Color.WHITE)
	
	for i in range(30):
		var particle = ColorRect.new()
		particle.size = Vector2(randf_range(5, 12), randf_range(5, 12))
		particle.color = color if randf() > 0.3 else Color(1, 1, 1)
		particle.position = center
		parent.add_child(particle)
		
		var angle = randf() * TAU
		var speed = randf_range(100, 300)
		var target = center + Vector2(cos(angle), sin(angle)) * speed
		
		var tween = parent.create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", target, randf_range(0.6, 1.2)).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, randf_range(0.6, 1.2)).set_ease(Tween.EASE_IN)
		tween.set_parallel(false)
		tween.tween_callback(particle.queue_free)
