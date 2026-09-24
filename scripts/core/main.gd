extends Node

const SITE_SCENE: PackedScene = preload("res://scenes/levels/construction_site.tscn")
const MENU_SCENE: PackedScene = preload("res://scenes/ui/main_menu.tscn")
const EXPORT_ROUND_SMOKE = preload("res://scripts/qa/export_round_smoke.gd")

var _current: Node

func _ready() -> void:
	show_menu()
	if OS.get_cmdline_user_args().has("--qa-round"):
		call_deferred("_run_export_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level2-round"):
		call_deferred("_run_export_level_two_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level3-round"):
		call_deferred("_run_export_level_three_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-round"):
		call_deferred("_run_export_visual_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-level3-round"):
		call_deferred("_run_export_visual_level_three_smoke")

func _run_export_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self)
	get_tree().quit(0 if passed else 1)

func _run_export_level_two_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 2)
	get_tree().quit(0 if passed else 1)

func _run_export_level_three_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 3)
	get_tree().quit(0 if passed else 1)

func _run_export_visual_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true)
	get_tree().quit(0 if passed else 1)

func _run_export_visual_level_three_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true, 3)
	get_tree().quit(0 if passed else 1)

func show_menu() -> void:
	_replace(MENU_SCENE)
	_current.start_requested.connect(start_game)
	_current.settings_changed.connect($AudioController.apply_settings)

func start_game(mode: String = "career", topic: String = "", level: int = 1) -> void:
	if is_instance_valid(_current):
		_current.queue_free()
	_current = SITE_SCENE.instantiate()
	_current.mode = mode
	_current.practice_topic = topic
	_current.level = level
	add_child(_current)
	_current.exit_requested.connect(show_menu)
	_current.feedback_given.connect($AudioController.play_feedback)
	_current.station_used.connect($AudioController.play_interact)
	_current.footstep.connect($AudioController.play_footstep)

func _replace(scene: PackedScene) -> void:
	if is_instance_valid(_current):
		_current.queue_free()
	_current = scene.instantiate()
	add_child(_current)
