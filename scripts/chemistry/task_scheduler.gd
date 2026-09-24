extends RefCounted

static func order_tasks(tasks: Array, mastery: Dictionary) -> Array:
	var remaining := tasks.duplicate()
	var ordered: Array = []
	while not remaining.is_empty():
		var best_index := 0
		var best_score := -INF
		for index in range(remaining.size()):
			var task: Dictionary = remaining[index]
			var topic_record: Dictionary = mastery.get(str(task.get("topic", "")), {})
			var topic_mastery := clampf(float(topic_record.get("mastery", 0.5)), 0.0, 1.0)
			var score := (0.5 - topic_mastery) * 4.0 - float(index) * 0.005
			if not ordered.is_empty():
				var previous: Dictionary = ordered.back()
				if previous.get("station", "") != task.get("station", ""):
					score += 1.5
				if previous.get("topic", "") != task.get("topic", ""):
					score += 1.1
				else:
					score -= 1.5
				for recent_index in range(maxi(0, ordered.size() - 3), ordered.size()):
					var recent: Dictionary = ordered[recent_index]
					if recent.get("topic", "") == task.get("topic", ""):
						score -= 1.2
					if recent.get("interactionType", "") == task.get("interactionType", ""):
						score -= 0.8
					if recent.get("station", "") == task.get("station", ""):
						score -= 0.7
			if score > best_score:
				best_score = score
				best_index = index
		ordered.append(remaining.pop_at(best_index))
	return ordered

static func schedule_related(tasks: Array, failed_index: int) -> bool:
	if failed_index < 0 or failed_index >= tasks.size():
		return false
	var failed: Dictionary = tasks[failed_index]
	var target_index := mini(failed_index + 3, tasks.size() - 1)
	if target_index <= failed_index + 1:
		return false
	var best_index := -1
	var best_score := -INF
	for index in range(failed_index + 1, tasks.size()):
		var candidate: Dictionary = tasks[index]
		if candidate.get("topic", "") != failed.get("topic", "") or candidate.get("id", "") == failed.get("id", ""):
			continue
		var score := 1.0
		if candidate.get("subtopic", "") == failed.get("subtopic", ""):
			score += 1.0
		var shared_tags := 0
		for tag in candidate.get("tags", []):
			if tag in failed.get("tags", []):
				shared_tags += 1
		score -= float(shared_tags) * 0.3
		score -= absf(float(index - target_index)) * 0.05
		if score > best_score:
			best_score = score
			best_index = index
	if best_index < 0:
		return false
	var related: Dictionary = tasks[best_index]
	tasks.remove_at(best_index)
	tasks.insert(target_index, related)
	return true
