class_name SettingsUI
extends Control
## UI component for the Settings/Config tab

const GameState = preload("res://scripts/data/game_state.gd")

signal reset_requested
signal ui_scale_changed(new_scale: float)
signal sound_toggled(enabled: bool)
signal settings_reset

var game_state
var save_manager
var settings_list: VBoxContainer


func setup(state, sav_manager) -> void:
	game_state = state
	save_manager = sav_manager


func refresh() -> void:
	if settings_list == null:
		return
	
	for child in settings_list.get_children():
		# Keep the back button if it exists
		if child.name == "MobileBackButton":
			continue
		child.queue_free()
	
	# Section header
	_add_section_header("SETTINGS", ThemeColors.STEEL_LIGHT)
	
	_add_spacer(15)
	
	# UI Scale section
	_add_section_header("Display", ThemeColors.ACCENT_SECONDARY)
	_create_ui_scale_slider()
	_add_spacer(10)
	_create_reset_settings_button()
	
	_add_spacer(20)
	
	# Audio section
	_add_section_header("Audio", ThemeColors.ACCENT_SECONDARY)
	_create_sound_toggle()
	
	_add_spacer(20)
	
	# Danger Zone section
	_add_section_header("Danger Zone", Color(1.0, 0.4, 0.4))
	_add_spacer(10)
	_create_reset_button()
	
	_add_spacer(30)
	
	# Credits section
	_add_section_header("About", ThemeColors.STEEL_DARK)
	_create_credits()


func _add_spacer(height: int) -> void:
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	settings_list.add_child(spacer)


func _add_section_header(text: String, color: Color) -> void:
	var header = Label.new()
	header.text = text
	header.add_theme_color_override("font_color", color)
	header.add_theme_font_size_override("font_size", 16)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_list.add_child(header)


func _create_ui_scale_slider() -> void:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	
	# Current scale label
	var scale_label = Label.new()
	scale_label.name = "ScaleLabel"
	scale_label.text = "UI Scale: %.0f%%" % (game_state.ui_scale * 100)
	scale_label.add_theme_font_size_override("font_size", 14)
	scale_label.add_theme_color_override("font_color", ThemeColors.STEEL_LIGHT)
	scale_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(scale_label)
	
	# Slider
	var slider = HSlider.new()
	slider.min_value = 0.8
	slider.max_value = 1.5
	slider.step = 0.05
	slider.value = game_state.ui_scale
	slider.custom_minimum_size = Vector2(200, 30)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(_on_ui_scale_changed.bind(scale_label))
	vbox.add_child(slider)
	
	# Hint text
	var hint = Label.new()
	hint.text = "Adjust text and UI element size"
	hint.add_theme_font_size_override("font_size", 11)
	hint.add_theme_color_override("font_color", ThemeColors.STEEL_DARK)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)
	
	settings_list.add_child(vbox)


func _on_ui_scale_changed(value: float, label: Label) -> void:
	game_state.ui_scale = value
	label.text = "UI Scale: %.0f%%" % (value * 100)
	ui_scale_changed.emit(value)


func _create_reset_settings_button() -> void:
	var reset_settings_btn = Button.new()
	reset_settings_btn.text = "Reset to Default (100%)"
	reset_settings_btn.custom_minimum_size = Vector2(0, 40)
	reset_settings_btn.add_theme_font_size_override("font_size", 12)
	reset_settings_btn.add_theme_color_override("font_color", ThemeColors.STEEL_LIGHT)
	reset_settings_btn.pressed.connect(_on_reset_settings_pressed)
	settings_list.add_child(reset_settings_btn)


func _on_reset_settings_pressed() -> void:
	game_state.ui_scale = 1.0
	game_state.sound_enabled = true
	ui_scale_changed.emit(1.0)
	sound_toggled.emit(true)
	settings_reset.emit()
	refresh()


func _create_sound_toggle() -> void:
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Label
	var label = Label.new()
	label.text = "Sound Effects"
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", ThemeColors.STEEL_LIGHT)
	hbox.add_child(label)
	
	# Toggle button
	var toggle = CheckButton.new()
	toggle.button_pressed = game_state.sound_enabled
	toggle.toggled.connect(_on_sound_toggled)
	hbox.add_child(toggle)
	
	settings_list.add_child(hbox)


func _on_sound_toggled(enabled: bool) -> void:
	game_state.sound_enabled = enabled
	sound_toggled.emit(enabled)


func _create_reset_button() -> void:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	
	# Warning text
	var warning = Label.new()
	warning.text = "This will delete ALL progress permanently!"
	warning.add_theme_font_size_override("font_size", 12)
	warning.add_theme_color_override("font_color", Color(0.8, 0.5, 0.5))
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(warning)
	
	# Reset button
	var reset_btn = Button.new()
	reset_btn.text = "RESET ALL PROGRESS"
	reset_btn.custom_minimum_size = Vector2(0, 50)
	reset_btn.add_theme_font_size_override("font_size", 14)
	reset_btn.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
	reset_btn.pressed.connect(_on_reset_pressed)
	vbox.add_child(reset_btn)
	
	settings_list.add_child(vbox)


func _on_reset_pressed() -> void:
	reset_requested.emit()


func _create_credits() -> void:
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	
	var title = Label.new()
	title.text = "Idle Blacksmith"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", ThemeColors.GOLD_TEXT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var version = Label.new()
	version.text = "Version 1.0.0"
	version.add_theme_font_size_override("font_size", 11)
	version.add_theme_color_override("font_color", ThemeColors.STEEL_DARK)
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(version)
	
	var credit = Label.new()
	credit.text = "Developed by Gabriel Nepomuceno"
	credit.add_theme_font_size_override("font_size", 12)
	credit.add_theme_color_override("font_color", ThemeColors.STEEL_LIGHT)
	credit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(credit)
	
	settings_list.add_child(vbox)
