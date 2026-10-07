extends Node

const SITE_SCENE: PackedScene = preload("res://scenes/levels/construction_site.tscn")
const MENU_SCENE: PackedScene = preload("res://scenes/ui/main_menu.tscn")
const EXPORT_ROUND_SMOKE = preload("res://scripts/qa/export_round_smoke.gd")
const KEYBOARD_ROUND_SMOKE = preload("res://scripts/qa/keyboard_round_smoke.gd")
const EXPORT_SITE_INSPECTION_SMOKE = preload("res://scripts/qa/export_site_inspection_smoke.gd")

const QA_PLAYTEST_SAVE := "user://qa_playtest_progress.json"
const QA_PLAYTEST_SETTINGS := "user://qa_playtest_settings.json"

var _current: Node
var _manual_playtest := false

func _ready() -> void:
	_manual_playtest = OS.get_cmdline_user_args().has("--qa-playtest") or OS.get_cmdline_user_args().has("--qa-keyboard-round")
	if _manual_playtest:
		$AudioController.apply_settings(preload("res://scripts/core/settings_data.gd").load_settings(QA_PLAYTEST_SETTINGS))
		print("CHEMSITE_MANUAL_PLAYTEST_ISOLATED")
	show_menu()
	if OS.get_cmdline_user_args().has("--qa-keyboard-round"):
		call_deferred("_run_keyboard_smoke")
	elif OS.get_cmdline_user_args().has("--qa-round"):
		call_deferred("_run_export_smoke")
	elif OS.get_cmdline_user_args().has("--qa-site-inspections"):
		call_deferred("_run_export_site_inspections")
	elif OS.get_cmdline_user_args().has("--qa-visual-site-inspections"):
		call_deferred("_run_export_visual_site_inspections")
	elif OS.get_cmdline_user_args().has("--qa-level2-round"):
		call_deferred("_run_export_level_two_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level3-round"):
		call_deferred("_run_export_level_three_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level3-scale-round"):
		call_deferred("_run_export_level_three_scale_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level3-solution-round"):
		call_deferred("_run_export_level_three_solution_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level3-ph-round"):
		call_deferred("_run_export_level_three_ph_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level3-ion-round"):
		call_deferred("_run_export_level_three_ion_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level3-hydrolysis-round"):
		call_deferred("_run_export_level_three_hydrolysis_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level3-dissociation-round"):
		call_deferred("_run_export_level_three_dissociation_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level4-round"):
		call_deferred("_run_export_level_four_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level4-hess-round"):
		call_deferred("_run_export_level_four_hess_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level4-kinetics-round"):
		call_deferred("_run_export_level_four_kinetics_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level4-equilibrium-round"):
		call_deferred("_run_export_level_four_equilibrium_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level4-electrode-round"):
		call_deferred("_run_export_level_four_electrode_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level4-corrosion-round"):
		call_deferred("_run_export_level_four_corrosion_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level5-round"):
		call_deferred("_run_export_level_five_smoke")
	elif OS.get_cmdline_user_args().has("--qa-level5-mission-round"):
		call_deferred("_run_export_level_five_mission_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-round"):
		call_deferred("_run_export_visual_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-level2-round"):
		call_deferred("_run_export_visual_level_two_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-level3-round"):
		call_deferred("_run_export_visual_level_three_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-level3-scale-round"):
		call_deferred("_run_export_visual_level_three_scale_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-level3-ph-round"):
		call_deferred("_run_export_visual_level_three_ph_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-level3-ion-round"):
		call_deferred("_run_export_visual_level_three_ion_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-level3-hydrolysis-round"):
		call_deferred("_run_export_visual_level_three_hydrolysis_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-level3-dissociation-round"):
		call_deferred("_run_export_visual_level_three_dissociation_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-level4-round"):
		call_deferred("_run_export_visual_level_four_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-level4-hess-round"):
		call_deferred("_run_export_visual_level_four_hess_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-level4-kinetics-round"):
		call_deferred("_run_export_visual_level_four_kinetics_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-level4-equilibrium-round"):
		call_deferred("_run_export_visual_level_four_equilibrium_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-level4-electrode-round"):
		call_deferred("_run_export_visual_level_four_electrode_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-level4-corrosion-round"):
		call_deferred("_run_export_visual_level_four_corrosion_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-level5-round"):
		call_deferred("_run_export_visual_level_five_smoke")
	elif OS.get_cmdline_user_args().has("--qa-visual-level5-mission-round"):
		call_deferred("_run_export_visual_level_five_mission_smoke")

func _run_export_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self)
	get_tree().quit(0 if passed else 1)

func _run_export_site_inspections() -> void:
	var passed: bool = await EXPORT_SITE_INSPECTION_SMOKE.run(self)
	get_tree().quit(0 if passed else 1)

func _run_export_visual_site_inspections() -> void:
	var passed: bool = await EXPORT_SITE_INSPECTION_SMOKE.run(self, true)
	get_tree().quit(0 if passed else 1)

func _run_export_level_two_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 2)
	get_tree().quit(0 if passed else 1)

func _run_export_level_three_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 3)
	get_tree().quit(0 if passed else 1)

func _run_export_level_three_scale_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 3, ["L3-086", "L3-087", "L3-088", "L3-089", "L3-090"])
	get_tree().quit(0 if passed else 1)

func _run_export_level_three_solution_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 3, ["L3-095", "L3-096", "L3-097", "L3-098", "L3-099"])
	get_tree().quit(0 if passed else 1)

func _run_export_level_three_ph_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 3, ["L3-101", "L3-102", "L3-103", "L3-107", "L3-104"])
	get_tree().quit(0 if passed else 1)

func _run_export_level_three_ion_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 3, ["L3-113", "L3-114", "L3-115", "L3-116", "L3-117"])
	get_tree().quit(0 if passed else 1)

func _run_export_level_three_hydrolysis_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 3, ["L3-117", "L3-118", "L3-119", "L3-116", "L3-120"])
	get_tree().quit(0 if passed else 1)

func _run_export_level_three_dissociation_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 3, ["L3-109", "L3-110", "L3-111", "L3-112", "L3-120"])
	get_tree().quit(0 if passed else 1)

func _run_export_level_four_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 4)
	get_tree().quit(0 if passed else 1)

func _run_export_level_four_hess_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 4, ["L4-126", "L4-127", "L4-128", "L4-129", "L4-130"])
	get_tree().quit(0 if passed else 1)

func _run_export_level_four_kinetics_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 4, ["L4-131", "L4-133", "L4-134", "L4-135", "L4-138"])
	get_tree().quit(0 if passed else 1)

func _run_export_level_four_equilibrium_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 4, ["L4-136", "L4-139", "L4-141", "L4-143", "L4-146"])
	get_tree().quit(0 if passed else 1)

func _run_export_level_four_electrode_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 4, ["L4-147", "L4-149", "L4-150", "L4-151", "L4-152"])
	get_tree().quit(0 if passed else 1)

func _run_export_level_four_corrosion_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 4, ["L4-153", "L4-154", "L4-156", "L4-158", "L4-159"])
	get_tree().quit(0 if passed else 1)

func _run_export_level_five_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 5)
	get_tree().quit(0 if passed else 1)

func _run_export_level_five_mission_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, false, 5, ["L5-180", "L5-190", "L5-196", "L5-198", "L5-200"])
	get_tree().quit(0 if passed else 1)

func _run_export_visual_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true)
	get_tree().quit(0 if passed else 1)

func _run_export_visual_level_two_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true, 2)
	get_tree().quit(0 if passed else 1)

func _run_export_visual_level_three_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true, 3)
	get_tree().quit(0 if passed else 1)

func _run_export_visual_level_three_scale_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true, 3, ["L3-086", "L3-087", "L3-088", "L3-089", "L3-090"])
	get_tree().quit(0 if passed else 1)

func _run_export_visual_level_three_ph_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true, 3, ["L3-101", "L3-102", "L3-103", "L3-107", "L3-104"])
	get_tree().quit(0 if passed else 1)

func _run_export_visual_level_three_ion_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true, 3, ["L3-113", "L3-114", "L3-115", "L3-116", "L3-117"])
	get_tree().quit(0 if passed else 1)

func _run_export_visual_level_three_hydrolysis_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true, 3, ["L3-117", "L3-118", "L3-119", "L3-116", "L3-120"])
	get_tree().quit(0 if passed else 1)

func _run_export_visual_level_three_dissociation_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true, 3, ["L3-109", "L3-110", "L3-111", "L3-112", "L3-120"])
	get_tree().quit(0 if passed else 1)

func _run_export_visual_level_four_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true, 4)
	get_tree().quit(0 if passed else 1)

func _run_export_visual_level_four_hess_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true, 4, ["L4-126", "L4-127", "L4-128", "L4-129", "L4-130"])
	get_tree().quit(0 if passed else 1)

func _run_export_visual_level_four_kinetics_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true, 4, ["L4-131", "L4-133", "L4-134", "L4-135", "L4-138"])
	get_tree().quit(0 if passed else 1)

func _run_export_visual_level_four_equilibrium_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true, 4, ["L4-136", "L4-139", "L4-141", "L4-143", "L4-146"])
	get_tree().quit(0 if passed else 1)

func _run_export_visual_level_four_electrode_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true, 4, ["L4-147", "L4-149", "L4-150", "L4-151", "L4-152"])
	get_tree().quit(0 if passed else 1)

func _run_export_visual_level_four_corrosion_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true, 4, ["L4-153", "L4-154", "L4-156", "L4-158", "L4-159"])
	get_tree().quit(0 if passed else 1)

func _run_export_visual_level_five_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true, 5)
	get_tree().quit(0 if passed else 1)

func _run_export_visual_level_five_mission_smoke() -> void:
	var passed: bool = await EXPORT_ROUND_SMOKE.run(self, true, 5, ["L5-180", "L5-190", "L5-196", "L5-198", "L5-200"])
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
	_configure_playtest_paths()
	add_child(_current)
	_current.exit_requested.connect(show_menu)
	_current.feedback_given.connect($AudioController.play_feedback)
	_current.station_used.connect($AudioController.play_interact)
	_current.footstep.connect($AudioController.play_footstep)

func _replace(scene: PackedScene) -> void:
	if is_instance_valid(_current):
		_current.queue_free()
	_current = scene.instantiate()
	_configure_playtest_paths()
	add_child(_current)

func _configure_playtest_paths() -> void:
	if _manual_playtest:
		_current.save_path = KEYBOARD_ROUND_SMOKE.SAVE_PATH if OS.get_cmdline_user_args().has("--qa-keyboard-round") else QA_PLAYTEST_SAVE
		_current.settings_path = QA_PLAYTEST_SETTINGS

func _run_keyboard_smoke() -> void:
	get_tree().create_timer(120).timeout.connect(func(): get_tree().quit(1))
	var passed: bool = await KEYBOARD_ROUND_SMOKE.run(self)
	get_tree().quit(0 if passed else 1)
