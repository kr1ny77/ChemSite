extends RefCounted

const SAVE_PATH := "user://progress.json"
const VERSION := 3

static func load_progress(path: String = SAVE_PATH) -> Dictionary:
	var defaults := {"save_version": VERSION, "best_score": 0, "best_stars": 0, "total_xp": 0, "completed_rounds": 0, "topic_mastery": {}, "mistakes": []}
	if not FileAccess.file_exists(path):
		return defaults
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return defaults
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return defaults
	var parsed: Variant = parser.data
	if not parsed is Dictionary or int(parsed.get("save_version", -1)) < 1 or int(parsed.get("save_version", -1)) > VERSION:
		return defaults
	for key in defaults.keys():
		if not parsed.has(key):
			parsed[key] = defaults[key]
	parsed.save_version = VERSION
	if not parsed.topic_mastery is Dictionary:
		parsed.topic_mastery = {}
	if not parsed.mistakes is Array:
		parsed.mistakes = []
	return parsed

static func record_answer(task: Dictionary, correct: bool, path: String = SAVE_PATH) -> Error:
	var progress := load_progress(path)
	var topic := str(task.get("topic", ""))
	var mastery: Dictionary = progress.topic_mastery
	var saved_record: Variant = mastery.get(topic, {})
	var record: Dictionary = saved_record if saved_record is Dictionary else {}
	record.attempts = int(record.get("attempts", 0)) + 1
	record.last_attempt_at = int(Time.get_unix_time_from_system())
	if correct:
		record.correct = int(record.get("correct", 0)) + 1
		record.consecutive_correct = int(record.get("consecutive_correct", 0)) + 1
		record.mastery = minf(1.0, float(record.get("mastery", 0.5)) + 0.08)
		record.mistake_weight = maxi(0, int(record.get("mistake_weight", 0)) - 1)
	else:
		record.incorrect = int(record.get("incorrect", 0)) + 1
		record.consecutive_correct = 0
		record.mastery = maxf(0.0, float(record.get("mastery", 0.5)) - 0.12)
		record.mistake_weight = int(record.get("mistake_weight", 0)) + 1
		var mistakes: Array = progress.mistakes
		mistakes.append({"task_id": str(task.get("id", "")), "topic": topic, "subtopic": str(task.get("subtopic", "")), "at": record.last_attempt_at})
		if mistakes.size() > 100:
			mistakes.pop_front()
	progress.topic_mastery[topic] = record
	return _write_progress(progress, path)

static func record_round(score: int, completed: int, path: String = SAVE_PATH) -> Error:
	var progress := load_progress(path)
	progress.best_score = maxi(int(progress.best_score), score)
	if completed >= 5:
		var stars := 3 if score >= 600 else (2 if score >= 400 else 1)
		progress.best_stars = maxi(int(progress.best_stars), stars)
	progress.total_xp = int(progress.total_xp) + completed * 50
	progress.completed_rounds = int(progress.completed_rounds) + 1
	return _write_progress(progress, path)

static func _write_progress(progress: Dictionary, path: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(progress))
	file.close()
	return OK
