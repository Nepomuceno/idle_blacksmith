class_name AudioManager
extends Node
## Handles all game audio

var forge_sound: AudioStreamPlayer
var upgrade_sound: AudioStreamPlayer
var ascend_sound: AudioStreamPlayer

const SOUNDS_PATH = "res://assets/ui/Sounds/"


func _ready() -> void:
	_setup_audio_players()
	_load_sounds()
	_connect_signals()


func _setup_audio_players() -> void:
	forge_sound = AudioStreamPlayer.new()
	add_child(forge_sound)
	
	upgrade_sound = AudioStreamPlayer.new()
	add_child(upgrade_sound)
	
	ascend_sound = AudioStreamPlayer.new()
	add_child(ascend_sound)


func _load_sounds() -> void:
	if ResourceLoader.exists(SOUNDS_PATH + "tap-a.ogg"):
		forge_sound.stream = load(SOUNDS_PATH + "tap-a.ogg")
		forge_sound.volume_db = -5
	
	if ResourceLoader.exists(SOUNDS_PATH + "click-a.ogg"):
		upgrade_sound.stream = load(SOUNDS_PATH + "click-a.ogg")
		upgrade_sound.volume_db = -8
	
	if ResourceLoader.exists(SOUNDS_PATH + "switch-b.ogg"):
		ascend_sound.stream = load(SOUNDS_PATH + "switch-b.ogg")
		ascend_sound.volume_db = 0


func _connect_signals() -> void:
	GameEvents.play_sound.connect(_on_play_sound)


func _on_play_sound(sound_type: String) -> void:
	play(sound_type)


func play(sound_type: String) -> void:
	match sound_type:
		"forge":
			if forge_sound.stream:
				forge_sound.play()
		"upgrade":
			if upgrade_sound.stream:
				upgrade_sound.play()
		"ascend":
			if ascend_sound.stream:
				ascend_sound.play()
		"tab":
			if upgrade_sound.stream:
				upgrade_sound.play()
		"achievement":
			if ascend_sound.stream:
				ascend_sound.play()
