## Splash Screen Controller
## Displays game intro with lore and animated loading sequence
## Transitions to main game after loading completes

extends Control

## Loading messages shown during splash
const LOADING_MESSAGES: Array[String] = [
	"Heating the forge...",
	"Gathering ancient metals...",
	"Awakening the spirits...",
	"Sharpening the tools...",
	"Igniting the flames...",
	"Ready to forge legends!"
]

## Lore snippets shown randomly
const LORE_SNIPPETS: Array[String] = [
	"In the realm of Aethermoor, an ancient forge\nawaits a master worthy of its flames...",
	"They say the first blacksmith forged the stars,\nand his hammer still echoes through time...",
	"The Eternal Anvil has stood for a thousand years,\nwaiting for the one who would claim its power...",
	"From simple iron to legendary mythril,\nevery weapon tells a story of fire and will...",
	"Ancient souls whisper secrets of the craft\nto those patient enough to listen...",
	"The forge burns eternal, fed by ambition\nand the dreams of master smiths...",
]

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var loading_label: Label = %LoadingLabel
@onready var lore_label: Label = %LoreLabel
@onready var tap_prompt: Label = %TapPrompt
@onready var title_label: Label = %TitleLabel
@onready var anvil_icon: Label = %AnvilIcon

var _loading_progress: float = 0.0
var _is_loading_complete: bool = false
var _current_message_index: int = 0
var _anvil_glow_tween: Tween


func _ready() -> void:
	# Set platform-appropriate window size
	_configure_window_for_platform()
	
	# Select random lore
	lore_label.text = LORE_SNIPPETS[randi() % LORE_SNIPPETS.size()]
	
	# Start animations
	_start_anvil_animation()
	_start_loading_sequence()


func _configure_window_for_platform() -> void:
	var os_name = OS.get_name()
	
	# Desktop platforms get wide layout by default
	if os_name in ["Windows", "macOS", "Linux"]:
		# Set desktop window size (wide layout)
		var screen_size = DisplayServer.screen_get_size()
		var window_width = mini(1280, int(screen_size.x * 0.8))
		var window_height = mini(800, int(screen_size.y * 0.8))
		
		# Ensure minimum size for wide layout
		window_width = maxi(window_width, 1024)
		window_height = maxi(window_height, 600)
		
		DisplayServer.window_set_size(Vector2i(window_width, window_height))
		
		# Center window on screen
		var window_size = DisplayServer.window_get_size()
		var screen_center = screen_size / 2
		var window_pos = Vector2i(
			screen_center.x - window_size.x / 2,
			screen_center.y - window_size.y / 2
		)
		DisplayServer.window_set_position(window_pos)
	
	# Mobile platforms use their native orientation (already set in project.godot)


func _input(event: InputEvent) -> void:
	if _is_loading_complete:
		if event is InputEventMouseButton and event.pressed:
			_transition_to_game()
		elif event is InputEventScreenTouch and event.pressed:
			_transition_to_game()
		elif event is InputEventKey and event.pressed:
			_transition_to_game()


func _start_anvil_animation() -> void:
	# Pulsing glow effect on anvil
	_anvil_glow_tween = create_tween()
	_anvil_glow_tween.set_loops()
	_anvil_glow_tween.tween_property(
		anvil_icon, "theme_override_colors/font_color",
		Color(1, 0.8, 0.4, 1), 1.0
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_anvil_glow_tween.tween_property(
		anvil_icon, "theme_override_colors/font_color",
		Color(1, 0.5, 0.2, 1), 1.0
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


func _start_loading_sequence() -> void:
	# Simulate loading with timed progress
	var load_tween := create_tween()
	
	# Animate progress bar
	load_tween.tween_method(_update_progress, 0.0, 1.0, 2.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	load_tween.tween_callback(_on_loading_complete)


func _update_progress(value: float) -> void:
	_loading_progress = value
	progress_bar.value = value
	
	# Update loading message based on progress
	var message_index := int(value * (LOADING_MESSAGES.size() - 1))
	if message_index != _current_message_index:
		_current_message_index = message_index
		_animate_message_change(LOADING_MESSAGES[message_index])


func _animate_message_change(new_text: String) -> void:
	var tween := create_tween()
	tween.tween_property(loading_label, "modulate:a", 0.0, 0.1)
	tween.tween_callback(func(): loading_label.text = new_text)
	tween.tween_property(loading_label, "modulate:a", 1.0, 0.1)


func _on_loading_complete() -> void:
	_is_loading_complete = true
	
	# Hide loading elements
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(progress_bar, "modulate:a", 0.0, 0.3)
	tween.tween_property(loading_label, "modulate:a", 0.0, 0.3)
	
	# Show tap prompt with animation
	tween.set_parallel(false)
	tween.tween_callback(func(): 
		tap_prompt.visible = true
		tap_prompt.modulate.a = 0.0
	)
	tween.tween_property(tap_prompt, "modulate:a", 1.0, 0.3)
	
	# Pulse tap prompt
	tween.tween_callback(_start_tap_prompt_animation)


func _start_tap_prompt_animation() -> void:
	var pulse_tween := create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(tap_prompt, "modulate:a", 0.4, 0.8).set_ease(Tween.EASE_IN_OUT)
	pulse_tween.tween_property(tap_prompt, "modulate:a", 1.0, 0.8).set_ease(Tween.EASE_IN_OUT)


func _transition_to_game() -> void:
	# Prevent multiple transitions
	set_process_input(false)
	
	# Stop anvil animation
	if _anvil_glow_tween:
		_anvil_glow_tween.kill()
	
	# Fade out
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	)
