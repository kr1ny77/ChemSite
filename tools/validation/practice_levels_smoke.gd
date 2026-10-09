extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main := (load("res://scenes/main/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	var passed: bool = await preload("res://scripts/qa/practice_levels_smoke.gd").run(main)
	main.queue_free()
	await process_frame
	quit(0 if passed else 1)
