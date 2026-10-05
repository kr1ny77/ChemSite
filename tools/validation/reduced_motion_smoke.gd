extends SceneTree

const SITE = preload("res://scenes/levels/construction_site.tscn")
const SETTINGS = preload("res://scripts/core/settings_data.gd")
const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")
const SETTINGS_PATH := "user://reduced-motion-smoke-settings.json"
const SAVE_PATH := "user://reduced-motion-smoke-progress.json"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var tasks := TASK_BANK.load_verified_tasks(1)
	if not _check(not tasks.is_empty(), "not tasks.is_empty()"):
		return
	var task: Dictionary = tasks[0]
	for enabled in [true, false]:
		if not _check(SETTINGS.save_settings({"reduced_motion": enabled}, SETTINGS_PATH) == OK, "SETTINGS.save_settings({\"reduced_motion\": enabled}, SETTINGS_PATH) == OK"):
			return
		var site := SITE.instantiate()
		site.settings_path = SETTINGS_PATH
		site.save_path = SAVE_PATH
		root.add_child(site)
		await process_frame
		if not _check(site.reduced_motion == enabled, "site.reduced_motion == enabled"):
			return
		if not _check(site._player.reduced_motion == enabled, "site._player.reduced_motion == enabled"):
			return
		site._player.controls_enabled = false
		site._player.global_position = Vector3(2.0, 0.0, 0.0)
		await process_frame
		await process_frame
		if enabled:
			for edge in [Vector3(-9, 0.05, 0), Vector3(9, 0.05, 0), Vector3(0, 0.05, -7), Vector3(0, 0.05, 7)]:
				site._player.global_position = edge
				await process_frame
				await process_frame
				var expected: Vector3 = site._player.global_position * Vector3(0.6, 0, 0.6)
				if not _check(site._camera_rig.global_position.distance_to(expected) < 0.001, "site._camera_rig.global_position.distance_to(expected) < 0.001"):
					return
			for light in site._work_lights:
				if not _check(is_equal_approx(light.light_energy, 0.72), "is_equal_approx(light.light_energy, 0.72)"):
					return
		else:
			if not _check(site._camera_rig.global_position.length() > 0.001, "site._camera_rig.global_position.length() > 0.001"):
				return
		site._tasks = [task]
		site._task_index = 0
		site._active_station = str(task.station)
		var world_children: int = site._world.get_child_count()
		site._submit_answer(str(task.correctAnswer))
		if not _check(site._world.get_child_count() == world_children + (0 if enabled else 2), "site._world.get_child_count() == world_children + (0 if enabled else 2)"):
			return
		if not _check(site._hud.is_panel_open(), "site._hud.is_panel_open()"):
			return
		site.queue_free()
		await process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SETTINGS_PATH))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	print("REDUCED_MOTION_SMOKE_OK")
	quit()

func _check(condition: bool, message: String) -> bool:
	if not condition:
		push_error("Reduced-motion QA failed: " + message)
		quit(1)
	return condition
