extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var main := preload("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	var passed: bool = await preload("res://scripts/qa/syllabus_supplement_smoke.gd").run(main)
	main.queue_free()
	for frame in range(4): await process_frame
	await create_timer(.6).timeout
	quit(0 if passed else 1)
