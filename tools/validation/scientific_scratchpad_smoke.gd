extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var bench := preload("res://scripts/ui/learning_workbench.gd").new()
	root.add_child(bench)
	var input: LineEdit
	var calculate: Button
	for child in bench.get_children():
		if child is LineEdit: input = child
		if child is Button: calculate = child
	var checked := 0
	for test in [["20/1000", .02], ["exp(0)", 1.0], ["ln(exp(3))", 3.0], ["ln  (exp(2))", 2.0], ["sqrt(9)", 3.0], ["exp(50000/8.314*(1/300-1/320))", exp(50000.0/8.314*(1.0/300-1.0/320))]]:
		input.text = str(test[0])
		calculate.pressed.emit()
		var output := ""
		for label in bench.find_children("*", "Label", true, false):
			if label.text.begins_with("Результат:"): output = label.text
		assert(not output.is_empty(), str(test[0]))
		var value := float(output.trim_prefix("Результат: ").split(". Единицы")[0])
		assert(is_equal_approx(value, float(test[1])), str(test))
		checked += 1
	for invalid in ["load('res://project.godot')", "OS.execute(1)", "randi()", "pow(2,3)", "x".repeat(257)]:
		input.text = invalid
		calculate.pressed.emit()
		var rejected := false
		for label in bench.find_children("*", "Label", true, false):
			if label.text.begins_with("Используйте"): rejected = true
		assert(rejected, invalid)
	for invalid_math in ["1/0", "ln(0)", "sqrt(-1)", "exp(1000000)"]:
		input.text = invalid_math
		calculate.pressed.emit()
		var rejected := false
		for label in bench.find_children("*", "Label", true, false):
			if label.text.begins_with("Проверьте"): rejected = true
		assert(rejected, invalid_math)
	bench.queue_free()
	await process_frame
	print("SCIENTIFIC_SCRATCHPAD_OK numeric_cases=", checked, " rejected_cases=9")
	quit()
