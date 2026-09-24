extends RefCounted

const TASKS_PATH := "res://data/chemistry/curated_tasks.json"

static func load_verified_tasks(level: int = 1) -> Array[Dictionary]:
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
		if entry is Dictionary and entry.get("reviewStatus", "") == "verified" and int(entry.get("level", 0)) == level:
			result.append(entry)
	return result

static func validate_choice(task: Dictionary, answer: String) -> bool:
	var correct: Variant = task.get("correctAnswer", "")
	if correct is Dictionary:
		var numeric_text := answer.strip_edges().replace(",", ".")
		var unit := str(correct.get("unit", ""))
		if not unit.is_empty() and numeric_text.ends_with(unit):
			numeric_text = numeric_text.trim_suffix(unit).strip_edges()
		if not numeric_text.is_valid_float():
			return false
		var target := float(correct.get("value", 0.0))
		var tolerance := maxf(float(correct.get("absoluteTolerance", 0.0)), absf(target) * float(correct.get("relativeTolerance", 0.0)))
		return absf(numeric_text.to_float() - target) <= tolerance
	var interaction := str(task.get("interactionType", ""))
	var normalized := _normalize(answer, interaction)
	if normalized == _normalize(str(correct), interaction):
		return true
	for accepted in task.get("acceptedAnswers", []):
		if normalized == _normalize(str(accepted), interaction):
			return true
	return false

static func _normalize(value: String, interaction: String) -> String:
	var normalized := value.strip_edges()
	for pair in [["₀", "0"], ["₁", "1"], ["₂", "2"], ["₃", "3"], ["₄", "4"], ["₅", "5"], ["₆", "6"], ["₇", "7"], ["₈", "8"], ["₉", "9"]]:
		normalized = normalized.replace(pair[0], pair[1])
	if interaction == "formula-builder":
		return normalized.replace(" ", "")
	if interaction == "ion-builder":
		for pair in [["⁰", "0"], ["¹", "1"], ["²", "2"], ["³", "3"], ["⁴", "4"], ["⁵", "5"], ["⁶", "6"], ["⁷", "7"], ["⁸", "8"], ["⁹", "9"], ["⁺", "+"], ["⁻", "-"]]:
			normalized = normalized.replace(pair[0], pair[1])
		return normalized.replace("^", "").replace(" ", "")
	return " ".join(normalized.to_lower().replace("\t", " ").split(" ", false))
