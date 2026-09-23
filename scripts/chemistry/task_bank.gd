extends RefCounted

const TASKS_PATH := "res://data/chemistry/vertical_slice_tasks.json"

static func load_verified_tasks() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var file := FileAccess.open(TASKS_PATH, FileAccess.READ)
	if file == null:
		push_error("Chemistry task data missing: " + TASKS_PATH)
		return result
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Array:
		push_error("Chemistry task bank must be an array")
		return result
	for entry in parsed:
		if entry is Dictionary and entry.get("reviewStatus", "") == "verified":
			result.append(entry)
	return result

static func validate_choice(task: Dictionary, answer: String) -> bool:
	var normalized := answer.strip_edges().to_lower()
	if normalized == str(task.get("correctAnswer", "")).strip_edges().to_lower():
		return true
	for accepted in task.get("acceptedAnswers", []):
		if normalized == str(accepted).strip_edges().to_lower():
			return true
	return false
