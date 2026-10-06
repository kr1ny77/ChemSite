extends SceneTree

const SAVE = preload("res://scripts/core/save_data.gd")
const SETTINGS = preload("res://scripts/core/settings_data.gd")

func _initialize() -> void:
	call_deferred("_run")
	create_timer(30).timeout.connect(func(): quit(1))

func _run() -> void:
	assert(OS.get_cmdline_user_args().has("--qa-playtest"))
	var prior_progress := FileAccess.get_sha256(ProjectSettings.globalize_path(SAVE.SAVE_PATH))
	var prior_settings := FileAccess.get_sha256(ProjectSettings.globalize_path(SETTINGS.SETTINGS_PATH))
	var main := (load("res://scenes/main/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	assert(main._current.save_path == main.QA_PLAYTEST_SAVE)
	assert(main._current.settings_path == main.QA_PLAYTEST_SETTINGS)
	main.start_game("career", "", 1)
	var site: Node = main._current
	assert(site.save_path == main.QA_PLAYTEST_SAVE)
	assert(site.settings_path == main.QA_PLAYTEST_SETTINGS)
	var before: Dictionary = SAVE.load_progress(main.QA_PLAYTEST_SAVE)
	site._submit_answer(str(site._tasks[0].correctAnswer))
	var after: Dictionary = SAVE.load_progress(main.QA_PLAYTEST_SAVE)
	assert(after.topic_mastery != before.topic_mastery)
	main.show_menu()
	assert(main._current.save_path == main.QA_PLAYTEST_SAVE)
	assert(FileAccess.get_sha256(ProjectSettings.globalize_path(SAVE.SAVE_PATH)) == prior_progress)
	assert(FileAccess.get_sha256(ProjectSettings.globalize_path(SETTINGS.SETTINGS_PATH)) == prior_settings)
	main.queue_free()
	for frame in range(5):
		await process_frame
	print("MANUAL_PLAYTEST_ISOLATION_OK")
	quit()
