extends Node3D

signal exit_requested
signal feedback_given(correct: bool)
signal station_used
signal footstep

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")
const TASK_SCHEDULER = preload("res://scripts/chemistry/task_scheduler.gd")
const SITE_INSPECTIONS = preload("res://scripts/world/site_inspections.gd")
const STATION_CONFIG := [
	{"id": "substance-storage", "name": "СКЛАД ВЕЩЕСТВ", "position": Vector3(-3.3, 0.0, -3.5), "model": "substance_storage"},
	{"id": "formula-board", "name": "ДОСКА ФОРМУЛ", "position": Vector3(5.7, 0.0, -3.4), "model": "formula_board"},
	{"id": "periodic-table-terminal", "name": "ПЕРИОДИЧЕСКАЯ СИСТЕМА", "position": Vector3(5.5, 0.0, 4.5), "model": "periodic_terminal"},
]
const LEVEL_TWO_STATIONS := [
	{"id": "reaction-bench", "name": "РЕАКЦИОННЫЙ СТОЛ", "position": Vector3(-3.3, 0.0, -3.5), "model": "reaction_bench"},
	{"id": "mixing-station", "name": "СМЕСИТЕЛЬНАЯ СТАНЦИЯ", "position": Vector3(5.7, 0.0, -3.4), "model": "mixing_station"},
	{"id": "ionic-reaction-station", "name": "ИОННАЯ ЛАБОРАТОРИЯ", "position": Vector3(5.5, 0.0, 4.5), "model": "ionic_reaction_station"},
	{"id": "inspection-station", "name": "КОНТРОЛЬ МАТЕРИАЛОВ", "position": Vector3(-3.8, 0.0, 0.8), "model": "inspection_station"},
]
const LEVEL_THREE_STATIONS := [
	{"id": "solution-laboratory", "name": "ЛАБОРАТОРИЯ РАСТВОРОВ", "position": Vector3(-3.3, 0.0, -3.5), "model": "solution_laboratory"},
	{"id": "ionic-reaction-station", "name": "ИОННАЯ ЛАБОРАТОРИЯ", "position": Vector3(5.7, 0.0, -3.4), "model": "ionic_reaction_station"},
	{"id": "inspection-station", "name": "КОНТРОЛЬ МАТЕРИАЛОВ", "position": Vector3(5.5, 0.0, 4.5), "model": "inspection_station"},
]
const LEVEL_FOUR_STATIONS := [
	{"id": "reaction-bench", "name": "РЕАКЦИОННЫЙ СТОЛ", "position": Vector3(-3.3, 0.0, -3.5), "model": "reaction_bench"},
	{"id": "electrochemistry-station", "name": "ЭЛЕКТРОХИМИЯ", "position": Vector3(5.7, 0.0, -3.4), "model": "electrochemistry_station"},
	{"id": "corrosion-test-rig", "name": "ИСПЫТАНИЕ КОРРОЗИИ", "position": Vector3(5.5, 0.0, 4.5), "model": "corrosion_test_rig"},
	{"id": "inspection-station", "name": "КОНТРОЛЬ МАТЕРИАЛОВ", "position": Vector3(-3.8, 0.0, 0.8), "model": "inspection_station"},
]
const LEVEL_FIVE_STATIONS := [
	{"id": "construction-materials-station", "name": "ИСПЫТАНИЕ МАТЕРИАЛОВ", "position": Vector3(-3.3, 0.0, -3.5), "model": "construction_materials_station"},
	{"id": "reaction-bench", "name": "РЕАКЦИОННЫЙ СТОЛ", "position": Vector3(5.7, 0.0, -3.4), "model": "reaction_bench"},
	{"id": "corrosion-test-rig", "name": "ИСПЫТАНИЕ КОРРОЗИИ", "position": Vector3(5.5, 0.0, 4.5), "model": "corrosion_test_rig"},
	{"id": "inspection-station", "name": "КОНТРОЛЬ МАТЕРИАЛОВ", "position": Vector3(-3.8, 0.0, 0.8), "model": "inspection_station"},
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
var _streak: int = 0
var _time_left: float = 900.0
var _active_station: String = ""
var _hud: Control
var _nearest_station: Dictionary = {}
var _nearest_inspection: Dictionary = {}
var _site_inspections: Array[Dictionary] = []
var _round_done: bool = false
var _round_complete_pending: bool = false
var mode: String = "career"
var level: int = 1
var practice_topic: String = ""
var _target_count: int = 5
var _machinery_player: AudioStreamPlayer3D
var _work_lights: Array[OmniLight3D] = []
var _site_time: float = 0.0
var _station_accent_materials: Dictionary = {}
const SAVE_DATA = preload("res://scripts/core/save_data.gd")
const SETTINGS_DATA = preload("res://scripts/core/settings_data.gd")
const ANSWER_BURST = preload("res://scripts/effects/answer_burst.gd")
const STATION_PULSE = preload("res://scripts/effects/station_pulse.gd")
var save_path: String = SAVE_DATA.SAVE_PATH
var settings_path: String = SETTINGS_DATA.SETTINGS_PATH
var reduced_motion := false

func _ready() -> void:
	reduced_motion = bool(SETTINGS_DATA.load_settings(settings_path).reduced_motion)
	_player.reduced_motion = reduced_motion
	get_node("CameraRig/PlayerVisibility").reduced_motion = reduced_motion
	_camera.position = Vector3(10.0, 15.5, 19.0)
	_camera.look_at(Vector3(0.0, 0.0, 0.0), Vector3.UP)
	_load_tasks()
	_site_inspections = SITE_INSPECTIONS.load_entries()
	_player.footstep.connect(func() -> void: footstep.emit())
	_build_world()
	if reduced_motion:
		for light in _work_lights:
			light.light_energy = 0.72
	_hud = preload("res://scenes/ui/game_hud.tscn").instantiate()
	_hud_layer.add_child(_hud)
	_hud.answer_submitted.connect(_submit_answer)
	_hud.resume_requested.connect(_resume)
	_hud.exit_requested.connect(func() -> void: exit_requested.emit())
	_update_hud()

func _process(delta: float) -> void:
	if not reduced_motion:
		_site_time += delta
		for index in range(_work_lights.size()):
			_work_lights[index].light_energy = 0.72 + 0.14 * sin(_site_time * 1.5 + float(index) * 2.1)
	var follow_target := _player.global_position * Vector3(0.6, 0.0, 0.6)
	if reduced_motion:
		_camera_rig.global_position = follow_target
	else:
		_camera_rig.global_position = _camera_rig.global_position.lerp(follow_target, 1.0 - exp(-3.0 * delta))
	if _round_done or not _player.controls_enabled:
		return
	if mode == "career":
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
	elif event.is_action_pressed("interact") and not event.is_echo() and _player.controls_enabled:
		if not _nearest_station.is_empty():
			_active_station = _nearest_station.id
			_player.controls_enabled = false
			_player.play_interact()
			station_used.emit()
			if _active_station == _tasks[_task_index].station:
				_hud.show_task(_tasks[_task_index], _active_station)
			else:
				_hud.show_wrong_station(_tasks[_task_index], _nearest_station)
		elif not _nearest_inspection.is_empty():
			_player.controls_enabled = false
			_player.play_interact()
			_hud.show_site_note(_nearest_inspection)

func _load_tasks() -> void:
	_tasks = TASK_BANK.load_verified_tasks(level)
	if mode == "practice":
		_tasks = _tasks.filter(func(task: Dictionary) -> bool: return task.topic == practice_topic)
		_target_count = mini(5, _tasks.size())
		if _tasks.is_empty():
			push_error("No verified practice tasks for topic: " + practice_topic)
	else:
		var progress: Dictionary = SAVE_DATA.load_progress(save_path)
		_tasks = TASK_SCHEDULER.order_tasks(_tasks, progress.topic_mastery)

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
	# Keep ground beneath every camera position so the site reads as part of a yard.
	_block("Construction yard", Vector3(0, -0.62, 0), Vector3(90, 0.12, 90), Color("b9b9a8"), true)
	_block("Service apron", Vector3(0, -0.595, -17), Vector3(90, 0.025, 8), Color("929d93"), false)
	_block("Foundation", Vector3(0, -0.30, 0), Vector3(90, 0.6, 90), Color("d7c9ad"), true)
	# Visual overlays sit 1–3 mm above the same physical walking plane.
	_block("Work zone surface", Vector3(0, -0.004, 0), Vector3(19, 0.01, 14), Color("d5c7ab"), false)
	_block("CentralPath", Vector3(0, -0.0035, 0.2), Vector3(3.6, 0.012, 12.5), Color("bbc7bc"), false)
	_block("RearPath", Vector3(0, -0.003, -3.4), Vector3(14, 0.012, 2.5), Color("bbc7bc"), false)
	_build_path_markings()
	_block("BuildPad", Vector3(-5.2, 0.07, 4.1), Vector3(6.3, 0.13, 4.3), Color("b5b9ad"), true)
	_environment_prop("construction_shell", Vector3(-5.6, 0.14, 4.1))
	_environment_prop("rebar_bay", Vector3(-2.5, 0.14, 4.0))
	_block("Rebar bay collision", Vector3(-2.5, 1.34, 4.0), Vector3(2.35, 2.4, 1.26), Color(0, 0, 0, 0), true)
	_build_perimeter()
	_environment_prop("site_cabin", Vector3(0.0, 0.0, -5.65))
	_block("Site laboratory cabin collision", Vector3(0.0, 1.15, -5.65), Vector3(3.85, 2.3, 1.8), Color(0, 0, 0, 0), true)
	_environment_prop("sample_cart", Vector3(-6.15, 0.0, -5.2))
	_block("Sample cart collision", Vector3(-6.15, 0.61, -5.2), Vector3(1.5, 1.22, 0.86), Color(0, 0, 0, 0), true)
	_environment_prop("safety_point", Vector3(3.2, 0.0, -5.15))
	_block("Safety point collision", Vector3(3.2, 1.06, -5.15), Vector3(1.85, 2.12, 0.9), Color(0, 0, 0, 0), true)
	for z in [2.68, 5.52]:
		for x in [-8.02, -3.18]:
			_block("Construction column collision", Vector3(x, 1.53, z), Vector3(0.73, 2.8, 0.73), Color(0, 0, 0, 0), true)
	_prop("crane", Vector3(-9.8, 0, -5.3), 1.2, 0.0)
	_environment_prop("site_mixer", Vector3(7.55, 0.0, -1.35))
	_add_machinery_ambience(Vector3(7.55, 1.0, -1.35))
	_block("Site mixer collision", Vector3(7.55, 0.77, -1.35), Vector3(1.8, 1.55, 1.75), Color(0, 0, 0, 0), true)
	_environment_prop("water_bay", Vector3(9.7, 0.0, 3.0))
	_block("Water bay collision", Vector3(9.7, 0.825, 3.0), Vector3(2.12, 1.65, 1.12), Color(0, 0, 0, 0), true)
	_environment_prop("sample_bench", Vector3(-9.6, 0.0, 0.4))
	_block("Sample bench collision", Vector3(-9.6, 0.82, 0.4), Vector3(2.2, 1.64, 1.25), Color(0, 0, 0, 0), true)
	_environment_prop("material_cache", Vector3(4.7, 0.0, 0.1))
	_block("Material cache collision", Vector3(4.7, 0.65, 0.1), Vector3(3.8, 1.3, 1.55), Color(0, 0, 0, 0), true)
	for i in range(3):
		_prop("cone", Vector3(-1.8 + i * 1.5, 0, 5.6), 1.0, 0.0)
	_prop("structure-yellow-medium", Vector3(-7.7, 0, -1.6), 1.2, 0.15)
	_block("Storage frame collision", Vector3(-7.7, 0.7, -1.6), Vector3(0.75, 1.4, 0.75), Color(0, 0, 0, 0), true)
	_prop("structure-yellow-tall", Vector3(-8.1, 0, 4.0), 1.2, 0.0)
	_block("Scaffold collision", Vector3(-8.1, 0.7, 4.0), Vector3(0.7, 1.4, 0.7), Color(0, 0, 0, 0), true)
	_prop("warning-orange", Vector3(-0.9, 0.0, -5.65), 1.6, 0.0)
	_block("Safety marker collision", Vector3(-0.9, 0.55, -5.65), Vector3(0.55, 1.1, 0.55), Color(0, 0, 0, 0), true)
	_prop("structure-yellow-medium", Vector3(7.6, 0.0, -5.1), 0.85, 0.0)
	_block("Machinery frame collision", Vector3(7.6, 0.55, -5.1), Vector3(0.65, 1.1, 0.65), Color(0, 0, 0, 0), true)
	_prop("lever-double", Vector3(7.2, 0.0, 5.3), 1.1, PI)
	_block("Lever collision", Vector3(7.2, 0.55, 5.3), Vector3(0.65, 1.1, 0.65), Color(0, 0, 0, 0), true)
	for station in _stations():
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
		_work_lights.append(task_light)
	for entry in _site_inspections:
		_block("Inspection marker", entry.position + Vector3(0, 0.025, 0), Vector3(0.42, 0.018, 0.42), Color("48a7ad"), false)

func _build_perimeter() -> void:
	# A bounded, readable site replaces the broad empty walkable apron.
	for z in [-9.5, 9.5]:
		for index in range(7):
			_environment_prop("site_fence", Vector3(-10.5 + float(index) * 3.5, 0, z))
		_block("Fence boundary", Vector3(0, 1.0, z), Vector3(24.5, 2.0, 0.16), Color(0, 0, 0, 0), true)
	for x in [-12.25, 12.25]:
		for index in range(5):
			_environment_prop("site_fence", Vector3(x, 0, -7.0 + float(index) * 3.5), PI * 0.5)
		_block("Fence boundary", Vector3(x, 1.0, 0), Vector3(0.16, 2.0, 19.0), Color(0, 0, 0, 0), true)

func _add_machinery_ambience(position: Vector3) -> void:
	var stream := load("res://assets/audio/machinery_loop.wav") as AudioStreamWAV
	if stream == null:
		return
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	var player := AudioStreamPlayer3D.new()
	player.name = "Mixer Ambience"
	player.stream = stream
	player.bus = "SFX"
	player.position = position
	player.volume_db = -10.0
	player.unit_size = 3.0
	player.max_distance = 25.0
	player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	_world.add_child(player)
	_machinery_player = player
	if DisplayServer.get_name() != "headless":
		player.play()

func _exit_tree() -> void:
	if is_instance_valid(_machinery_player):
		_machinery_player.stop()
		_machinery_player.stream = null

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

func _build_path_markings() -> void:
	var dash := BoxMesh.new()
	dash.size = Vector3(0.12, 0.002, 0.58)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("eee2bd")
	material.roughness = 0.9
	var markings := MultiMesh.new()
	markings.transform_format = MultiMesh.TRANSFORM_3D
	markings.mesh = dash
	markings.instance_count = 19
	for index in range(9):
		markings.set_instance_transform(index, Transform3D(Basis(), Vector3(0.0, 0.0036, -2.1 + float(index) * 0.9)))
	var across := Basis(Vector3.UP, PI * 0.5)
	for index in range(10):
		markings.set_instance_transform(9 + index, Transform3D(across, Vector3(-5.2 + float(index) * 1.1, 0.0041, -3.4)))
	var visual := MultiMeshInstance3D.new()
	visual.name = "Walkway markings"
	visual.multimesh = markings
	visual.material_override = material
	_world.add_child(visual)

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
	for node in prop.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		if mesh.name.begins_with("Periodic element") or mesh.name.begins_with("Formula glyph") or mesh.name.begins_with("Amber header marker") or mesh.name == "Side sample analyzer":
			var original := mesh.get_active_material(0) as StandardMaterial3D
			if original != null:
				var key := original.resource_name
				if not _station_accent_materials.has(key):
					var accent := original.duplicate() as StandardMaterial3D
					accent.emission_enabled = true
					accent.emission = original.albedo_color
					accent.emission_energy_multiplier = 0.45
					_station_accent_materials[key] = accent
				mesh.material_override = _station_accent_materials[key]
	_world.add_child(prop)

func _environment_prop(asset_name: String, pos: Vector3, yaw: float = 0.0) -> void:
	var scene := load("res://assets/models/environment/%s.glb" % asset_name) as PackedScene
	if scene == null:
		push_error("Environment asset missing: " + asset_name)
		return
	var prop := scene.instantiate() as Node3D
	prop.position = pos
	prop.rotation.y = yaw
	_world.add_child(prop)
	if asset_name in ["construction_shell", "site_cabin", "rebar_bay"]:
		for mesh in prop.find_children("*", "MeshInstance3D", true, false):
			mesh.add_to_group("player_camera_occluder")

func _find_nearest_station() -> void:
	_nearest_station = {}
	_nearest_inspection = {}
	var nearest_distance := 2.6
	for station in _stations():
		var distance := _player.global_position.distance_to(station.position)
		if distance < nearest_distance:
			nearest_distance = distance
			_nearest_station = station
	var nearest_inspection_distance := 1.9
	for entry in _site_inspections:
		var distance := _player.global_position.distance_to(entry.position)
		if distance < nearest_inspection_distance:
			nearest_inspection_distance = distance
			_nearest_inspection = entry
	if not _nearest_station.is_empty() and not _nearest_inspection.is_empty():
		if nearest_inspection_distance + 0.4 < nearest_distance:
			_nearest_station = {}
		else:
			_nearest_inspection = {}

func _update_hud() -> void:
	if _tasks.is_empty():
		return
	_hud.update_status(_tasks[mini(_task_index, _tasks.size() - 1)], _completed, _score, _time_left, _nearest_station, _streak, _target_count, mode, _nearest_inspection)

func _submit_answer(answer: String) -> void:
	if _round_done or _tasks.is_empty():
		return
	var task: Dictionary = _tasks[_task_index]
	var valid: bool = TASK_BANK.validate_choice(task, answer)
	if mode == "career":
		var learning_error: Error = SAVE_DATA.record_answer(task, valid, save_path)
		if learning_error != OK:
			push_warning("Could not save topic mastery: %s" % error_string(learning_error))
	feedback_given.emit(valid)
	if not reduced_motion:
		var burst := ANSWER_BURST.new() as GPUParticles3D
		_world.add_child(burst)
		burst.global_position = _player.global_position + Vector3(0, 2.4, 0)
		burst.start(valid)
		for station in _stations():
			if station.id == _active_station:
				var pulse := STATION_PULSE.new() as Node3D
				_world.add_child(pulse)
				pulse.global_position = station.position + Vector3(0, 0.11, 0)
				pulse.start(valid)
				break
	if valid:
		_streak += 1
		var multiplier := 2.0 if _streak >= 5 else (1.5 if _streak >= 3 else 1.0)
		var awarded := int(roundi(float(task.get("points", 100)) * multiplier))
		_score += awarded
		_completed += 1
		_hud.update_round_stats(_completed, _score, _time_left, _streak, mode)
		_player.play_reaction(true)
		_hud.show_feedback(true, task, awarded, _streak)
	else:
		_streak = 0
		_hud.update_round_stats(_completed, _score, _time_left, _streak, mode)
		_player.play_reaction(false)
		_hud.show_feedback(false, task, 0, _streak)
		if mode == "career":
			TASK_SCHEDULER.schedule_related(_tasks, _task_index)
	_task_index += 1
	if _completed >= _target_count or _task_index >= _tasks.size():
		_round_complete_pending = true

func _finish_round() -> void:
	if _round_done:
		return
	_round_done = true
	_player.controls_enabled = false
	_update_hud()
	if mode == "career":
		var save_error: Error = SAVE_DATA.record_round(_score, _completed, save_path, level)
		if save_error != OK:
			push_warning("Could not save round progress: %s" % error_string(save_error))
	_hud.show_results(_score, _completed, _time_left, _target_count, mode)

func _resume() -> void:
	if _round_done:
		return
	if _round_complete_pending:
		_finish_round()
		return
	_hud.close_panel()
	_player.clear_reaction()
	_player.controls_enabled = true
	_find_nearest_station()
	_update_hud()

func _stations() -> Array:
	match level:
		2: return LEVEL_TWO_STATIONS
		3: return LEVEL_THREE_STATIONS
		4: return LEVEL_FOUR_STATIONS
		5: return LEVEL_FIVE_STATIONS
	return STATION_CONFIG
