extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var main := preload("res://scenes/main/main.tscn").instantiate()
	root.add_child(main)
	var passed: bool = await preload("res://scripts/qa/study_audio_smoke.gd").run(main)
	main.queue_free()
	await process_frame
	quit(0 if passed else 1)
