extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var main := (load("res://scenes/main/main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	await process_frame
	main.queue_free()
	await process_frame
	quit()
