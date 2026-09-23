extends Node

const MUSIC_PATH := "res://assets/audio/lofi-1.mp3"
const SUCCESS_PATH := "res://assets/audio/correct.wav"
const ERROR_PATH := "res://assets/audio/incorrect.wav"
const INTERACT_PATH := "res://assets/audio/interact.wav"

var _music: AudioStreamPlayer
var _effects: AudioStreamPlayer

func _ready() -> void:
	_music = AudioStreamPlayer.new()
	_music.bus = "Music"
	_music.volume_db = -8.0
	add_child(_music)
	if DisplayServer.get_name() != "headless":
		var music_stream := load(MUSIC_PATH) as AudioStreamMP3
		if music_stream:
			music_stream.loop = true
			_music.stream = music_stream
			_music.play()
	_effects = AudioStreamPlayer.new()
	_effects.bus = "SFX"
	_effects.volume_db = -4.0
	add_child(_effects)

func play_feedback(correct: bool) -> void:
	_effects.stream = load(SUCCESS_PATH if correct else ERROR_PATH) as AudioStream
	_effects.play()

func play_interact() -> void:
	_effects.stream = load(INTERACT_PATH) as AudioStream
	_effects.play()

func _exit_tree() -> void:
	if is_instance_valid(_music):
		_music.stop()
		_music.stream = null
	if is_instance_valid(_effects):
		_effects.stop()
		_effects.stream = null
