extends Node3D

signal exit_requested
signal feedback_given(correct: bool)
signal station_used

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")
const STATION_CONFIG := [
	{"id": "substance-storage", "name": "СКЛАД ВЕЩЕСТВ", "position": Vector3(-3.3, 0.0, -3.5), "model": "substance_storage"},
	{"id": "formula-board", "name": "ДОСКА ФОРМУЛ", "position": Vector3(5.7, 0.0, -3.4), "model": "formula_board"},
	{"id": "periodic-table-terminal", "name": "ПЕРИОДИЧЕСКАЯ СИСТЕМА", "position": Vector3(5.5, 0.0, 4.5), "model": "periodic_terminal"},
]

@onready var _world: Node3D = $World
@onready var _player: CharacterBody3D = $Player
@onready var _camera_rig: Node3D = $CameraRig
@onready var _camera: Camera3D = $CameraRig/Camera3D
@onready var _hud_layer: CanvasLayer = $CanvasLayer

var _tasks: Array = []
var _task_index: int = 0
var _completed: int = 0
var _score: int = 0
var _time_left: float = 900.0
var _active_station: String = ""
var _hud: Control
var _nearest_station: Dictionary = {}
var _round_done: bool = false
const SAVE_DATA = preload("res://scripts/core/save_data.gd")
const ANSWER_BURST = preload("res://scripts/effects/answer_burst.gd")
const STATION_PULSE = preload("res://scripts/effects/station_pulse.gd")
var save_path: String = SAVE_DATA.SAVE_PATH

func _ready() -> void:
	_camera.position = Vector3(10.0, 15.5, 19.0)
	_camera.look_at(Vector3(0.0, 0.0, 0.0), Vector3.UP)
	_load_tasks()
	_build_world()
	_hud = preload("res://scenes/ui/game_hud.tscn").instantiate()
	_hud_layer.add_child(_hud)
	_hud.answer_submitted.connect(_submit_answer)
	_hud.resume_requested.connect(_resume)
	_hud.exit_requested.connect(func() -> void: exit_requested.emit())
	_update_hud()

func _process(delta: float) -> void:
	_camera_rig.global_position = _camera_rig.global_position.lerp(_player.global_position * Vector3(0.6, 0.0, 0.6), 1.0 - exp(-3.0 * delta))
	if _round_done or not _player.controls_enabled:
		return
	_time_left = maxf(0.0, _time_left - delta)
	if _time_left <= 0.0:
		_finish_round()
	_find_nearest_station()
	_update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if _round_done or _tasks.is_empty():
		return
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		if _hud.is_panel_open():
			_resume()
		else:
			_player.controls_enabled = false
			_hud.show_pause()
	elif event.is_action_pressed("interact") and not event.is_echo() and _player.controls_enabled and not _nearest_station.is_empty():
		_active_station = _nearest_station.id
		_player.controls_enabled = false
		_player.play_interact()
		station_used.emit()
		if _active_station == _tasks[_task_index].station:
			_hud.show_task(_tasks[_task_index], _active_station)
		else:
			_hud.show_wrong_station(_tasks[_task_index], _nearest_station)

func _load_tasks() -> void:
	_tasks = TASK_BANK.load_verified_tasks()

func _build_world() -> void:
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("a7cbd0")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("b8d2cd")
	settings.ambient_light_energy = 0.32
	settings.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	settings.ssao_enabled = true
	settings.ssao_radius = 0.9
	settings.ssao_intensity = 1.25
	environment.environment = settings
	_world.add_child(environment)
	_block("Foundation", Vector3(0, -0.32, 0), Vector3(19, 0.6, 14), Color("d7c9ad"), true)
	_block("CentralPath", Vector3(0, 0.01, 0.2), Vector3(3.6, 0.03, 12.5), Color("bbc7bc"), false)
	_block("RearPath", Vector3(0, 0.015, -3.4), Vector3(14, 0.03, 2.5), Color("bbc7bc"), false)
	_block("BuildPad", Vector3(-5.2, 0.07, 4.1), Vector3(6.3, 0.13, 4.3), Color("b5b9ad"), true)
	_environment_prop("rebar_bay", Vector3(-2.5, 0.14, 4.0))
	_block("Rebar bay collision", Vector3(-2.5, 1.34, 4.0), Vector3(2.35, 2.4, 1.26), Color(0, 0, 0, 0), true)
	for x in [-8.7, 8.7]:
		_block("Perimeter", Vector3(x, 0.62, 0), Vector3(0.25, 1.2, 14), Color("304c57"), true)
	for z in [-6.8, 6.8]:
		_block("Perimeter", Vector3(0, 0.62, z), Vector3(17.5, 1.2, 0.25), Color("304c57"), true)
	_environment_prop("site_cabin", Vector3(0.0, 0.0, -5.65))
	_block("Site laboratory cabin collision", Vector3(0.0, 1.15, -5.65), Vector3(3.85, 2.3, 1.8), Color(0, 0, 0, 0), true)
	_environment_prop("safety_point", Vector3(3.2, 0.0, -5.15))
	_block("Safety point collision", Vector3(3.2, 1.06, -5.15), Vector3(1.85, 2.12, 0.9), Color(0, 0, 0, 0), true)
	for z in [2.3, 5.5]:
		for x in [-7.4, -3.2]:
			_prop("column-wide", Vector3(x, 0.14, z), 1.55, 0.0)
			_block("Column collision", Vector3(x, 0.9, z), Vector3(0.7, 1.8, 0.7), Color(0, 0, 0, 0), true)
	_prop("wall-half", Vector3(-5.3, 0.14, 5.8), 1.9, 0.0)
	_prop("crane", Vector3(-9.8, 0, -5.3), 1.2, 0.0)
	_environment_prop("site_mixer", Vector3(7.55, 0.0, -1.35))
	_block("Site mixer collision", Vector3(7.55, 0.77, -1.35), Vector3(1.8, 1.55, 1.75), Color(0, 0, 0, 0), true)
	_environment_prop("material_cache", Vector3(4.7, 0.0, 0.1))
	_block("Material cache collision", Vector3(4.7, 0.65, 0.1), Vector3(3.8, 1.3, 1.55), Color(0, 0, 0, 0), true)
	for i in range(3):
		_prop("cone", Vector3(-1.8 + i * 1.5, 0, 5.6), 1.0, 0.0)
	_prop("structure-yellow-medium", Vector3(-7.7, 0, -1.6), 1.2, 0.15)
	_block("Storage frame collision", Vector3(-7.7, 0.7, -1.6), Vector3(0.75, 1.4, 0.75), Color(0, 0, 0, 0), true)
	_prop("structure-yellow-tall", Vector3(-8.1, 0, 4.0), 1.2, 0.0)
	_prop("wall-window-wide-square-detailed", Vector3(-5.2, 0.14, 2.3), 2.1, 0.0)
	_block("Scaffold collision", Vector3(-8.1, 0.7, 4.0), Vector3(0.7, 1.4, 0.7), Color(0, 0, 0, 0), true)
	_prop("catwalk-straight", Vector3(-5.35, 2.35, 4.1), 1.7, 0.0)
	_prop("warning-orange", Vector3(-0.9, 0.0, -5.65), 1.6, 0.0)
	_block("Safety marker collision", Vector3(-0.9, 0.55, -5.65), Vector3(0.55, 1.1, 0.55), Color(0, 0, 0, 0), true)
	_prop("structure-yellow-medium", Vector3(7.6, 0.0, -5.1), 0.85, 0.0)
	_block("Machinery frame collision", Vector3(7.6, 0.55, -5.1), Vector3(0.65, 1.1, 0.65), Color(0, 0, 0, 0), true)
	_prop("lever-double", Vector3(7.2, 0.0, 5.3), 1.1, PI)
	_block("Lever collision", Vector3(7.2, 0.55, 5.3), Vector3(0.65, 1.1, 0.65), Color(0, 0, 0, 0), true)
	for station in STATION_CONFIG:
		_station_prop(station.model, station.position)
		_block(station.name, station.position + Vector3(0, 0.03, 0), Vector3(2.3, 0.06, 2.3), Color("efa945"), false)
		_block(station.name + " collider", station.position + Vector3(0, 0.55, 0), Vector3(1.3, 1.1, 1.1), Color(0, 0, 0, 0), true)
		var task_light := OmniLight3D.new()
		task_light.name = station.name + " Work Light"
		task_light.position = station.position + Vector3(0, 2.1, 0)
		task_light.light_color = Color("6ed9dc")
		task_light.light_energy = 0.8
		task_light.omni_range = 3.4
		_world.add_child(task_light)

func _block(label: String, pos: Vector3, dimensions: Vector3, color: Color, solid: bool) -> void:
	if color.a > 0.0:
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.84
		var mesh := BoxMesh.new()
		mesh.size = dimensions
		var visual := MeshInstance3D.new()
		visual.name = label
		visual.mesh = mesh
		visual.material_override = material
		visual.position = pos
		_world.add_child(visual)
	if solid:
		var body := StaticBody3D.new()
		body.position = pos
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = dimensions
		shape.shape = box
		body.add_child(shape)
		_world.add_child(body)

func _prop(asset_name: String, pos: Vector3, scale_value: float, yaw: float) -> void:
	var scene := load("res://assets/models/construction/%s.glb" % asset_name) as PackedScene
	if scene == null:
		return
	var prop := scene.instantiate() as Node3D
	prop.position = pos
	prop.scale = Vector3.ONE * scale_value
	prop.rotation.y = yaw
	var finish := StandardMaterial3D.new()
	finish.roughness = 0.72
	if asset_name in ["column-wide", "wall-half", "wall-window-wide-square-detailed"]:
		finish.albedo_color = Color("b8bec0")
	elif asset_name in ["crane", "structure-yellow-medium", "structure-yellow-tall"]:
		finish.albedo_color = Color("dca34a")
		finish.metallic = 0.25
	elif asset_name in ["stairs-open-short", "catwalk-straight", "pipe-large-long"]:
		finish.albedo_color = Color("809a9a")
		finish.metallic = 0.4
	elif asset_name in ["machine", "hopper-high-round"]:
		finish.albedo_color = Color("496b70")
		finish.metallic = 0.35
	elif asset_name in ["screen-wide", "scanner-high"]:
		finish.albedo_color = Color("247d91")
		finish.metallic = 0.35
	elif asset_name in ["cone", "warning-orange"]:
		finish.albedo_color = Color("e8872d")
	elif asset_name.begins_with("box"):
		finish.albedo_color = Color("ad8253")
	else:
		finish.albedo_color = Color("5d7d83")
		finish.metallic = 0.25
	_apply_finish(prop, finish)
	_world.add_child(prop)

func _apply_finish(node: Node, finish: StandardMaterial3D) -> void:
	if node is MeshInstance3D:
		(node as MeshInstance3D).material_override = finish
	for child in node.get_children():
		_apply_finish(child, finish)

func _station_prop(asset_name: String, pos: Vector3) -> void:
	var scene := load("res://assets/models/stations/%s.glb" % asset_name) as PackedScene
	if scene == null:
		push_error("Station asset missing: " + asset_name)
		return
	var prop := scene.instantiate() as Node3D
	prop.position = pos
	_world.add_child(prop)

func _environment_prop(asset_name: String, pos: Vector3) -> void:
	var scene := load("res://assets/models/environment/%s.glb" % asset_name) as PackedScene
	if scene == null:
		push_error("Environment asset missing: " + asset_name)
		return
	var prop := scene.instantiate() as Node3D
	prop.position = pos
	_world.add_child(prop)

func _find_nearest_station() -> void:
	_nearest_station = {}
	var nearest_distance := 2.6
	for station in STATION_CONFIG:
		var distance := _player.global_position.distance_to(station.position)
		if distance < nearest_distance:
			nearest_distance = distance
			_nearest_station = station

func _update_hud() -> void:
	if _tasks.is_empty():
		return
	_hud.update_status(_tasks[_task_index], _completed, _score, _time_left, _nearest_station)

func _submit_answer(answer: String) -> void:
	if _round_done or _tasks.is_empty():
		return
	var task: Dictionary = _tasks[_task_index]
	var valid: bool = TASK_BANK.validate_choice(task, answer)
	feedback_given.emit(valid)
	var burst := ANSWER_BURST.new() as GPUParticles3D
	_world.add_child(burst)
	burst.global_position = _player.global_position + Vector3(0, 2.4, 0)
	burst.start(valid)
	for station in STATION_CONFIG:
		if station.id == _active_station:
			var pulse := STATION_PULSE.new() as Node3D
			_world.add_child(pulse)
			pulse.global_position = station.position + Vector3(0, 0.11, 0)
			pulse.start(valid)
			break
	if valid:
		_score += 100
		_completed += 1
		_player.play_reaction(true)
		_hud.show_feedback(true, task)
		_task_index = (_task_index + 1) % _tasks.size()
	else:
		_player.play_reaction(false)
		_hud.show_feedback(false, task)
	if _completed >= 5:
		_finish_round()
	else:
		_update_hud()

func _finish_round() -> void:
	if _round_done:
		return
	_round_done = true
	_player.controls_enabled = false
	var save_error: Error = SAVE_DATA.record_round(_score, _completed, save_path)
	if save_error != OK:
		push_warning("Could not save round progress: %s" % error_string(save_error))
	_hud.show_results(_score, _completed, _time_left)

func _resume() -> void:
	if _round_done:
		return
	_hud.close_panel()
	_player.clear_reaction()
	_player.controls_enabled = true
