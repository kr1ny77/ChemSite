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
	assert(not tasks.is_empty())
	var task: Dictionary = tasks[0]
	for enabled in [true, false]:
		assert(SETTINGS.save_settings({"reduced_motion": enabled}, SETTINGS_PATH) == OK)
		var site := SITE.instantiate()
		site.settings_path = SETTINGS_PATH
		site.save_path = SAVE_PATH
		root.add_child(site)
		await process_frame
		assert(site.reduced_motion == enabled)
		assert(site._player.reduced_motion == enabled)
		site._player.global_position = Vector3(2.0, 0.0, 0.0)
		await process_frame
		await process_frame
		if enabled:
			assert(site._camera_rig.global_position.length() < 0.001)
			for light in site._work_lights:
				assert(is_equal_approx(light.light_energy, 0.72))
		else:
			assert(site._camera_rig.global_position.length() > 0.001)
		site._tasks = [task]
		site._task_index = 0
		site._active_station = str(task.station)
		var world_children: int = site._world.get_child_count()
		site._submit_answer(str(task.correctAnswer))
		assert(site._world.get_child_count() == world_children + (0 if enabled else 2))
		assert(site._hud.is_panel_open())
		site.queue_free()
		await process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SETTINGS_PATH))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	print("REDUCED_MOTION_SMOKE_OK")
	quit()
