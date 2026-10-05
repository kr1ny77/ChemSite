extends RefCounted

const PATH := "res://data/chemistry/site_inspections.json"

static func load_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var source := FileAccess.get_file_as_string(PATH)
	var parsed: Variant = JSON.parse_string(source)
	if not parsed is Array:
		push_error("Site inspections must be a JSON array")
		return entries
	for raw in parsed:
		if not raw is Dictionary:
			continue
		var entry: Dictionary = raw
		var coordinates: Variant = entry.get("position", [])
		if not entry.has("id") or not entry.has("name") or not entry.has("text") or not coordinates is Array or coordinates.size() != 3:
			push_error("Invalid site inspection entry: " + str(entry.get("id", "unknown")))
			continue
		entry.position = Vector3(float(coordinates[0]), float(coordinates[1]), float(coordinates[2]))
		entries.append(entry)
	return entries
