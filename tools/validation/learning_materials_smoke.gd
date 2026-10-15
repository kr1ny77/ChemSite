extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	root.size = Vector2i(1028, 642)
	root.content_scale_size = Vector2i(1440, 900)
	var hud := preload("res://scenes/ui/game_hud.tscn").instantiate()
	root.add_child(hud)
	var task: Dictionary = preload("res://scripts/chemistry/task_bank.gd").load_verified_tasks(3)[70]
	hud.show_task(task, task.station)
	var input: LineEdit
	for child in hud._panel_content.get_children():
		if child is LineEdit: input = child
	assert(input != null)
	input.text = "12.6"
	var material_button: Button
	for button in hud.find_children("*", "Button", true, false):
		if button.text == "МАТЕРИАЛЫ": material_button = button
	assert(material_button != null)
	material_button.pressed.emit()
	var overlay: Node = hud.get_child(hud.get_child_count() - 1)
	await process_frame
	assert(overlay.initial_material == "acid")
	input.grab_focus()
	await process_frame
	await process_frame
	assert(overlay.is_ancestor_of(root.gui_get_focus_owner()), "Materials focus escaped to the covered answer")
	for index in range(overlay._catalog.size()):
		overlay._display(index)
		await process_frame
		assert(overlay.size.x <= 1440 and overlay.size.y <= 900)
	overlay._display(overlay._catalog.size())
	await process_frame
	var bench: Node = overlay._content.get_child(0)
	var expression: LineEdit
	var compute: Button
	for child in bench.get_children():
		if child is LineEdit: expression = child
		if child is Button: compute = child
	expression.text = "(2+3)*4/1000"
	compute.pressed.emit()
	var found := false
	for label in bench.find_children("*", "Label", true, false):
		if label.text.begins_with("Результат: 0.02"): found = true
	assert(found)
	expression.text = "load('res://project.godot')"
	compute.pressed.emit()
	found = false
	for label in bench.find_children("*", "Label", true, false):
		if label.text.begins_with("Используйте числа"): found = true
	assert(found)
	bench._protons = 11
	bench._neutrons = 12
	bench._charge = 1
	bench._refresh()
	assert("Электроны: 10" in bench._result.text)
	overlay._close()
	await process_frame
	assert(input.text == "12.6")
	hud.queue_free()
	await process_frame
	print("LEARNING_MATERIALS_SMOKE_OK 11 references, contextual opening, calculator, atom model, retained answer")
	quit()
