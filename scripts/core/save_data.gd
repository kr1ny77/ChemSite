extends RefCounted

const SAVE_PATH := "user://progress.json"
const VERSION := 1

static func load_progress(path: String = SAVE_PATH) -> Dictionary:
	var defaults := {"save_version": VERSION, "best_score": 0, "total_xp": 0, "completed_rounds": 0}
	if not FileAccess.file_exists(path):
		return defaults
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return defaults
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary or parsed.get("save_version", -1) != VERSION:
		return defaults
	for key in defaults.keys():
		if not parsed.has(key):
			parsed[key] = defaults[key]
	return parsed

static func record_round(score: int, completed: int, path: String = SAVE_PATH) -> Error:
	var progress := load_progress(path)
	progress.best_score = maxi(int(progress.best_score), score)
	progress.total_xp = int(progress.total_xp) + completed * 50
	progress.completed_rounds = int(progress.completed_rounds) + 1
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(progress))
	return OK
