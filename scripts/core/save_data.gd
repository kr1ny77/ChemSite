extends RefCounted

const SAVE_PATH := "user://progress.json"
const VERSION := 5

static func load_progress(path: String = SAVE_PATH) -> Dictionary:
	var defaults := {"save_version": VERSION, "best_score": 0, "best_stars": 0, "total_xp": 0, "completed_rounds": 0, "topic_mastery": {}, "mistakes": [], "unlocked_level": 1, "level_records": {}}
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
	if int(parsed.best_stars) > 0:
		parsed.unlocked_level = maxi(2, int(parsed.unlocked_level))
	if not parsed.topic_mastery is Dictionary:
		parsed.topic_mastery = {}
	if not parsed.mistakes is Array:
		parsed.mistakes = []
	if not parsed.level_records is Dictionary:
		parsed.level_records = {}
	return parsed

static func record_answer(task: Dictionary, correct: bool, path: String = SAVE_PATH) -> Error:
	var progress := load_progress(path)
	var topic := str(task.get("topic", ""))
	var level := int(task.get("level", 1))
	var mastery_key := "%d:%s" % [level, topic]
	var mastery: Dictionary = progress.topic_mastery
	var saved_record: Variant = mastery.get(mastery_key, mastery.get(topic, {}) if level == 1 else {})
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
	progress.topic_mastery[mastery_key] = record
	return _write_progress(progress, path)

static func record_round(score: int, completed: int, path: String = SAVE_PATH, level: int = 1) -> Error:
	var progress := load_progress(path)
	if level < 1 or level > 5:
		return ERR_INVALID_PARAMETER
	progress.best_score = maxi(int(progress.best_score), score)
	var records: Dictionary = progress.level_records
	var key := str(level)
	var prior: Variant = records.get(key, {})
	var record: Dictionary = prior if prior is Dictionary else {}
	record.best_score = maxi(int(record.get("best_score", 0)), score)
	record.rounds = int(record.get("rounds", 0)) + 1
	record.best_stars = int(record.get("best_stars", 0))
	if completed >= 5:
		var stars := 3 if score >= 600 else (2 if score >= 400 else 1)
		progress.best_stars = maxi(int(progress.best_stars), stars)
		record.best_stars = maxi(int(record.best_stars), stars)
		if level == 1:
			progress.unlocked_level = maxi(int(progress.unlocked_level), 2)
		elif level == 2:
			progress.unlocked_level = maxi(int(progress.unlocked_level), 3)
		elif level == 3:
			progress.unlocked_level = maxi(int(progress.unlocked_level), 4)
		elif level == 4:
			progress.unlocked_level = maxi(int(progress.unlocked_level), 5)
	progress.total_xp = int(progress.total_xp) + completed * 50
	progress.completed_rounds = int(progress.completed_rounds) + 1
	record.xp = int(record.get("xp", 0)) + completed * 50
	progress.level_records[key] = record
	return _write_progress(progress, path)

static func _write_progress(progress: Dictionary, path: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(progress))
	file.close()
	return OK
