extends RefCounted

const SETTINGS_PATH := "user://settings.json"
const VERSION := 1

static func load_settings(path: String = SETTINGS_PATH) -> Dictionary:
	var defaults := {"save_version": VERSION, "music_volume": 0.7, "sfx_volume": 0.8, "reduced_motion": false}
	if not FileAccess.file_exists(path):
		return defaults
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return defaults
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return defaults
	var parsed: Variant = parser.data
	if not parsed is Dictionary or parsed.get("save_version", -1) != VERSION:
		return defaults
	for key in ["music_volume", "sfx_volume"]:
		var value: Variant = parsed.get(key, defaults[key])
		parsed[key] = clampf(float(value) if value is float or value is int else defaults[key], 0.0, 1.0)
	parsed["reduced_motion"] = parsed.get("reduced_motion", false) == true
	return parsed

static func save_settings(settings: Dictionary, path: String = SETTINGS_PATH) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var clean := {
		"save_version": VERSION,
		"music_volume": clampf(float(settings.get("music_volume", 0.7)), 0.0, 1.0),
		"sfx_volume": clampf(float(settings.get("sfx_volume", 0.8)), 0.0, 1.0),
		"reduced_motion": settings.get("reduced_motion", false) == true,
	}
	file.store_string(JSON.stringify(clean))
	return OK
