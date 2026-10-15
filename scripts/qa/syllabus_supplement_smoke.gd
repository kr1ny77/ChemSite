extends RefCounted
const BANK = preload("res://scripts/chemistry/task_bank.gd")
const UI = preload("res://scripts/qa/export_round_smoke.gd")

static func run(main: Node) -> bool:
	var tree := main.get_tree()
	var root := tree.root
	var save_hash := FileAccess.get_sha256("user://progress.json")
	var submitted := [""]
	main._current.hide()
	root.size = Vector2i(1028, 642)
	root.content_scale_size = Vector2i(1440, 900)
	var hud := preload("res://scenes/ui/game_hud.tscn").instantiate()
	main.add_child(hud)
	hud.answer_submitted.connect(func(answer: String) -> void: submitted[0] = answer)
	var checked := 0
	var topics := {}
	for level in range(1, 6):
		for task in BANK.load_verified_tasks(level):
			if not "syllabus-supplement" in task.get("tags", []): continue
			hud.show_task(task, str(task.station))
			await tree.process_frame
			var material: Button
			for button in hud.find_children("*", "Button", true, false):
				if button.text == "МАТЕРИАЛЫ": material = button
			if material == null: return _fail("Materials button missing")
			material.pressed.emit()
			await tree.process_frame
			var overlay: Node = hud.get_child(hud.get_child_count() - 1)
			var expected := "physical"
			if task.topic == "Дисперсные системы": expected = "dispersions"
			elif task.topic == "Поверхностные явления": expected = "surface"
			elif task.topic in ["Органическая химия", "Полимерные материалы"]: expected = "organic"
			elif int(task.moduleId) == 9: expected = "kinetics"
			if overlay.initial_material != expected: return _fail(str(task.id) + " contextual reference")
			topics[str(task.topic)] = true
			overlay._close()
			await tree.process_frame
			submitted[0] = ""
			if not UI._answer_through_ui(hud, task): return _fail(str(task.id) + " UI input")
			if not BANK.validate_choice(task, submitted[0]): return _fail(str(task.id) + " actual UI answer")
			hud.show_feedback(true, task)
			await tree.process_frame
			checked += 1
	if checked != 53: return _fail("Expected 53 supplemental cases")
	var overlay := preload("res://scripts/ui/learning_materials.gd").new()
	hud.add_child(overlay)
	var selector: OptionButton = overlay.find_children("*", "OptionButton", true, false)[0]
	selector.select(overlay._catalog.size())
	selector.item_selected.emit(overlay._catalog.size())
	var bench: Node = overlay._content.get_child(0)
	var expression: LineEdit
	var compute: Button
	for child in bench.get_children():
		if child is LineEdit: expression = child
		if child is Button: compute = child
	for test in [["20/1000", .02], ["exp(0)", 1.0], ["ln(exp(3))", 3.0]]:
		expression.text = str(test[0])
		compute.pressed.emit()
		var result := ""
		for label in bench.find_children("*", "Label", true, false):
			if label.text.begins_with("Результат:"): result = label.text
		if result.is_empty(): return _fail("Scientific scratchpad produced no result")
		var value := float(result.trim_prefix("Результат: ").split(". Единицы")[0])
		if not is_equal_approx(value, float(test[1])): return _fail("Scientific scratchpad arithmetic")
	hud.queue_free()
	await tree.process_frame
	if FileAccess.get_sha256("user://progress.json") != save_hash: return _fail("Real progress changed")
	print("SYLLABUS_SUPPLEMENT_NATIVE_OK version=", ProjectSettings.get_setting("application/config/version"), " tasks=", checked, " topics=", topics.size(), " scientific=3 contextual_materials, UI answers, feedback")
	return true

static func _fail(message: String) -> bool:
	push_error("Syllabus supplement: " + message)
	return false
