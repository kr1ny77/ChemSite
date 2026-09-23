extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene := load("res://scenes/levels/construction_site.tscn") as PackedScene
	assert(scene != null)
	var instance := scene.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	assert(instance.get_node("Player") != null)
	assert(instance.get_node("CanvasLayer/GameHud") != null)
	print("CHEMSITE_SMOKE_OK")
	quit()
