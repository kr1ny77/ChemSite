extends SceneTree
const SAVE = preload("res://scripts/core/save_data.gd")
const BANK = preload("res://scripts/chemistry/task_bank.gd")
const SCHEDULER = preload("res://scripts/chemistry/task_scheduler.gd")
const PATH = "user://qa_career_history_isolated.json"
func _initialize() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({"save_version":5,"best_score":700,"mistakes":[{"task_id":"old-mistake"}]}))
	file.close()
	var progress := SAVE.load_progress(PATH)
	assert(progress.save_version == 6 and progress.best_score == 700)
	assert("old-mistake" in progress.career_answered_ids)
	var tasks := BANK.load_verified_tasks(1)
	assert(SAVE.record_answer(tasks[0], true, PATH) == OK)
	assert(SAVE.record_answer(tasks[1], false, PATH) == OK)
	assert(SAVE.record_answer(tasks[0], true, PATH) == OK)
	progress = SAVE.load_progress(PATH)
	assert(progress.career_answered_ids.size() == 3)
	var selected := SCHEDULER.order_tasks(tasks, {}, progress.career_answered_ids)
	assert(selected.size() == tasks.size() - 2)
	for task in selected:
		assert(task.id not in progress.career_answered_ids)
	var all_ids: Array = []
	for task in tasks:
		all_ids.append(task.id)
	assert(SCHEDULER.order_tasks(tasks, {}, all_ids).is_empty())
	assert(SCHEDULER.order_tasks(tasks, {}).size() == tasks.size())
	DirAccess.remove_absolute(PATH)
	print("CAREER_HISTORY_SMOKE_OK migration, correct/wrong, restart, deduplication, exhaustion, practice")
	quit()
