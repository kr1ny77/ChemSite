extends Node

const SETTINGS_DATA = preload("res://scripts/core/settings_data.gd")

const MUSIC_PATH := "res://assets/audio/lofi-1.mp3"
const SUCCESS_PATH := "res://assets/audio/correct.wav"
const ERROR_PATH := "res://assets/audio/incorrect.wav"
const INTERACT_PATH := "res://assets/audio/interact.wav"
const STEP_PATHS := ["res://assets/audio/step_a.wav", "res://assets/audio/step_b.wav", "res://assets/audio/step_c.wav", "res://assets/audio/step_d.wav"]
const STEP_PITCHES := [1.0, 0.99, 1.015, 0.985, 1.005, 1.01, 0.995, 1.0]

var _music: AudioStreamPlayer
var _effects: AudioStreamPlayer
var _steps: Array[AudioStreamPlayer] = []
var _step_index: int = 0

func _ready() -> void:
	apply_settings(SETTINGS_DATA.load_settings())
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
	for path in STEP_PATHS:
		var step := AudioStreamPlayer.new()
		step.bus = "SFX"
		step.volume_db = -18.0
		step.stream = load(path) as AudioStream
		add_child(step)
		_steps.append(step)

func apply_settings(settings: Dictionary) -> void:
	for entry in [{"bus": "Music", "key": "music_volume"}, {"bus": "SFX", "key": "sfx_volume"}]:
		var bus_index := AudioServer.get_bus_index(entry.bus)
		if bus_index >= 0:
			var volume := clampf(float(settings.get(entry.key, 1.0)), 0.0, 1.0)
			AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(volume, 0.001)))

func play_feedback(correct: bool) -> void:
	_effects.stream = load(SUCCESS_PATH if correct else ERROR_PATH) as AudioStream
	_effects.play()

func play_interact() -> void:
	_effects.stream = load(INTERACT_PATH) as AudioStream
	_effects.play()

func play_footstep() -> void:
	var step := _steps[_step_index % _steps.size()]
	step.pitch_scale = STEP_PITCHES[_step_index % STEP_PITCHES.size()]
	step.play()
	_step_index += 1

func _exit_tree() -> void:
	if is_instance_valid(_music):
		_music.stop()
		_music.stream = null
	if is_instance_valid(_effects):
		_effects.stop()
		_effects.stream = null
