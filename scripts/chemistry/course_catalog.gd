extends RefCounted
const PATH := "res://data/chemistry/course/progression.json"
static func data() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(PATH))
static func chapters() -> Array:
	return data().chapters
static func tasks(chapter: int) -> Array:
	var catalog := data()
	var all_tasks: Array = []
	for environment in range(1, 6):
		all_tasks.append_array(preload("res://scripts/chemistry/task_bank.gd").load_verified_tasks(environment))
	return all_tasks.filter(func(task: Dictionary) -> bool: return int(task.get("moduleId", catalog.taskChapters.get(task.id, 0))) == chapter)
