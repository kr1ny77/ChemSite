extends RefCounted

const DEFINITION = preload("res://data/progression/construction_stages.tres")

static func stage_from_progress(progress: Dictionary) -> int:
	var raw_records: Variant = progress.get("level_records", {})
	if not raw_records is Dictionary: return 0
	var records: Dictionary = raw_records
	var stage := 0
	# Legacy saves contain an earned Level 1 star record only at global scope.
	if records.is_empty() and int(progress.get("best_stars", 0)) > 0:
		stage = 1
	for level in range(stage + 1, 6):
		var record: Variant = records.get(str(level), {})
		if not record is Dictionary or int(record.get("best_stars", 0)) < 1:
			break
		stage = level
	return stage

static func stage_title(stage: int) -> String:
	return DEFINITION.stage_names[clampi(stage, 0, 5)]
