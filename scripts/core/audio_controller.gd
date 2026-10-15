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
var _ui: AudioStreamPlayer
var _liquid: AudioStreamPlayer
var _combo: AudioStreamPlayer
var _warning: AudioStreamPlayer

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
		step.volume_db = -32.0
		step.stream = load(path) as AudioStream
		add_child(step)
		_steps.append(step)
	_ui = _create_cue("res://assets/audio/ui_action.wav", "UI", -4.0)
	_liquid = _create_cue("res://assets/audio/liquid_mix.wav", "SFX", -10.0)
	_combo = _create_cue("res://assets/audio/combo.wav", "SFX", -10.0)
	_warning = _create_cue("res://assets/audio/timer_warning.wav", "SFX", -10.0)
	get_tree().node_added.connect(_connect_ui_action)

func _create_cue(path: String, bus_name: String, gain_db: float) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.stream = load(path) as AudioStream
	player.bus = bus_name
	player.volume_db = gain_db
	add_child(player)
	return player

func _connect_ui_action(node: Node) -> void:
	if node is BaseButton and not node.pressed.is_connected(play_ui_action):
		node.pressed.connect(play_ui_action)

func play_ui_action() -> void:
	_ui.play()

func play_liquid() -> void:
	_liquid.play()

func play_combo(_streak: int) -> void:
	_combo.play()

func play_timer_warning(_seconds: int) -> void:
	_warning.play()

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

func stop_all() -> void:
	for player in [_ui, _liquid, _combo, _warning, _music, _effects] + _steps:
		if is_instance_valid(player):
			player.stop()
			player.stream = null

func _exit_tree() -> void:
	stop_all()
