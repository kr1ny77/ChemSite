extends SceneTree

const TASK_BANK = preload("res://scripts/chemistry/task_bank.gd")
const TASK_SCHEDULER = preload("res://scripts/chemistry/task_scheduler.gd")
const SAVE_DATA = preload("res://scripts/core/save_data.gd")
const TEST_PATH := "user://learning-levels-smoke.json"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	for level in range(1, 6):
		var tasks: Array[Dictionary] = TASK_BANK.load_verified_tasks(level)
		var counts := {}
		for task in tasks:
			counts[task.topic] = int(counts.get(task.topic, 0)) + 1
		var target: Dictionary = tasks.filter(func(task: Dictionary) -> bool: return int(counts[task.topic]) >= 2)[0]
		assert(SAVE_DATA.record_answer(target, false, TEST_PATH) == OK)
		var progress: Dictionary = SAVE_DATA.load_progress(TEST_PATH)
		var key := "%d:%s" % [level, target.topic]
		assert(progress.topic_mastery.has(key) and progress.topic_mastery[key].incorrect == 1, "Level mastery missing: " + key)
		var ordered: Array = TASK_SCHEDULER.order_tasks(tasks, progress.topic_mastery)
		assert(ordered[0].topic == target.topic, "Weak topic was not prioritized: " + key)
		assert(TASK_SCHEDULER.schedule_related(ordered, 0), "Related task was not found: " + key)
		assert(ordered[3].topic == target.topic and ordered[3].id != ordered[0].id, "Related task was scheduled incorrectly: " + key)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))
	print("CHEMSITE_LEARNING_LEVELS_OK: 5 levels")
	quit()
