extends SceneTree
const BANK = preload("res://scripts/chemistry/task_bank.gd")
const FOLDER := "res://artifacts/syllabus-ui"

func _initialize() -> void:
	call_deferred("_run")

func _capture(name: String) -> void:
	for frame in range(6): await process_frame
	RenderingServer.force_draw(false)
	assert(root.get_texture().get_image().save_png(FOLDER.path_join(name + ".png")) == OK)

func _run() -> void:
	root.size = Vector2i(1028,642)
	root.content_scale_size = Vector2i(1440,900)
	DirAccess.make_dir_recursive_absolute(FOLDER)
	var site := preload("res://scenes/levels/construction_site.tscn").instantiate()
	site.level = 4
	site.save_path = "user://qa-syllabus-capture.json"
	root.add_child(site)
	site._player.controls_enabled = false
	await process_frame
	var hud: Node = site._hud
	var tasks := BANK.load_verified_tasks(4).filter(func(t: Dictionary) -> bool: return t.subtopic == "Уравнение Аррениуса")
	site._tasks = [tasks[0]]
	site._task_index = 0
	hud.update_status(tasks[0], 0, 0, 900.0, {})
	hud.show_task(tasks[0], str(tasks[0].station))
	await _capture("arrhenius-question")
	var polymer_tasks := BANK.load_verified_tasks(5).filter(func(t: Dictionary) -> bool: return t.subtopic in ["Схема цепной полимеризации", "Связь при поликонденсации"])
	for index in range(polymer_tasks.size()):
		var task: Dictionary = polymer_tasks[index]
		site._tasks = [task]
		hud.update_status(task, 0, 0, 900.0, {})
		hud.show_task(task, str(task.station))
		await _capture("polymer-equation-%d" % (index+1))
	var overlay := preload("res://scripts/ui/learning_materials.gd").new()
	hud.add_child(overlay)
	var selector: OptionButton = overlay.find_children("*", "OptionButton", true, false)[0]
	for index in range(overlay._catalog.size()):
		if overlay._catalog[index].id in ["dispersions","surface","organic","kinetics","physical"]:
			selector.select(index)
			selector.item_selected.emit(index)
			await _capture(str(overlay._catalog[index].id))
	selector.select(overlay._catalog.size())
	selector.item_selected.emit(overlay._catalog.size())
	var bench: Node = overlay._content.get_child(0)
	for child in bench.get_children():
		if child is LineEdit: child.text = "exp(50000/8.314*(1/300-1/320))"
	for child in bench.get_children():
		if child is Button: child.pressed.emit()
	await _capture("scientific-scratchpad")
	site.queue_free()
	await process_frame
	await process_frame
	DirAccess.remove_absolute("user://qa-syllabus-capture.json")
	print("SYLLABUS_MATERIALS_CAPTURE_OK images=10 actual_size=1028x642")
	quit()
