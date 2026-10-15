extends SceneTree

func _initialize() -> void:
	create_timer(20.0).timeout.connect(func(): quit(1))
	call_deferred("_run")

func _run() -> void:
	var main := Node.new()
	root.add_child(main)
	var passed: bool = await preload("res://scripts/qa/packaged_movement_smoke.gd").new().run(main)
	quit(0 if passed else 1)
