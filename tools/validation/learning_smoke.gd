extends SceneTree

const SAVE_DATA = preload("res://scripts/core/save_data.gd")
const TEST_PATH := "user://learning-smoke-progress.json"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.save_path = TEST_PATH
	root.add_child(site)
	await process_frame
	var first: Dictionary = site._tasks[0]
	site._active_station = first.station
	site._submit_answer("wrong-answer")
	assert(site._task_index == 1 and site._completed == 0 and site._streak == 0)
	assert(site._tasks[3].topic == first.topic and site._tasks[3].id != first.id, "Related question was not scheduled after two intervening tasks")
	var progress: Dictionary = SAVE_DATA.load_progress(TEST_PATH)
	var mastery: Dictionary = progress.topic_mastery["1:" + first.topic]
	assert(mastery.attempts == 1 and mastery.incorrect == 1 and is_equal_approx(mastery.mastery, 0.38))
	assert(progress.mistakes.size() == 1 and progress.mistakes[0].task_id == first.id)
	for index in range(2):
		var task: Dictionary = site._tasks[site._task_index]
		site._submit_answer(str(task.correctAnswer))
	assert(site._task_index == 3 and site._completed == 2)
	var seen: Dictionary = {}
	for task in site._tasks:
		assert(not seen.has(task.id), "Task repeated in round schedule")
		seen[task.id] = true
	site.queue_free()
	await process_frame
	var weak_path := "user://learning-weak-topic.json"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(weak_path))
	var bank: Array = load("res://scripts/chemistry/task_bank.gd").load_verified_tasks()
	var periodic: Dictionary = bank.filter(func(task: Dictionary) -> bool: return task.topic == "Периодическая система")[0]
	assert(SAVE_DATA.record_answer(periodic, false, weak_path) == OK)
	var level_three: Dictionary = periodic.duplicate(true)
	level_three.level = 3
	assert(SAVE_DATA.record_answer(level_three, false, weak_path) == OK)
	var separate: Dictionary = SAVE_DATA.load_progress(weak_path).topic_mastery
	assert(separate.has("1:" + periodic.topic) and separate.has("3:" + level_three.topic), "Mastery did not stay level-scoped")
	assert(separate["1:" + periodic.topic].attempts == 1 and separate["3:" + periodic.topic].attempts == 1, "Same-name topics shared attempts across levels")
	var next_site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	next_site.save_path = weak_path
	root.add_child(next_site)
	assert(next_site._tasks[0].topic == "Периодическая система", "Weak topic did not receive first priority")
	next_site.queue_free()
	await process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(weak_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	print("CHEMSITE_LEARNING_SMOKE_OK")
	quit()
