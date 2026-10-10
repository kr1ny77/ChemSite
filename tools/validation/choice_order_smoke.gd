extends SceneTree

const ORDER = preload("res://scripts/ui/choice_order.gd")
const BANK = preload("res://scripts/chemistry/task_bank.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var fixture := {"id": "fixture", "options": ["a", "b", "c", "d"]}
	var positions: Dictionary = {}
	for seed_value in range(128):
		var order = ORDER.new(seed_value)
		var actual: Array = order.options_for(fixture)
		positions[actual.find("a")] = true
		assert(actual == ORDER.new(seed_value).options_for(fixture))
		assert(actual == order.options_for(fixture), "Reopening changed order")
		actual.clear()
		assert(order.options_for(fixture).size() == 4, "Caller mutated cached order")
	assert(positions.size() == 4, "Correct answer must reach every position")
	assert(fixture.options == ["a", "b", "c", "d"])
	var hud := (load("res://scenes/ui/game_hud.tscn") as PackedScene).instantiate()
	hud._choice_order = ORDER.new(42)
	root.add_child(hud)
	var submitted := [""]
	hud.answer_submitted.connect(func(answer: String): submitted[0] = answer)
	var checked := 0
	for level in range(1, 6):
		for task in BANK.load_verified_tasks(level):
			if not task.get("options", []).has(task.correctAnswer): continue
			hud.show_task(task, str(task.station))
			await process_frame
			var cards: GridContainer
			for child in hud._panel_content.get_children():
				if child is GridContainer: cards = child
			if cards == null: continue
			var displayed: Array = []
			for button in cards.get_children(): displayed.append(button.text)
			var expected: Array = task.options.duplicate()
			var sorted_display := displayed.duplicate()
			expected.sort()
			sorted_display.sort()
			assert(expected == sorted_display, "Options changed")
			hud._set_answer_enabled(true)
			for button in cards.get_children():
				if button.text == task.correctAnswer:
					submitted[0] = ""
					button.pressed.emit()
					assert(submitted[0] == task.correctAnswer and BANK.validate_choice(task, submitted[0]))
			checked += 1
	print("CHOICE_ORDER_SMOKE_OK tasks=", checked, " positions=", positions.size())
	quit()
