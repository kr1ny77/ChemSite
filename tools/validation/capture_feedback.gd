extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	await process_frame
	site._submit_answer("сульфат бария")
	site._resume()
	await create_timer(0.2).timeout
	await process_frame
	var image := root.get_viewport().get_texture().get_image()
	var error := image.save_png("res://artifacts/godot-feedback.png")
	print("FEEDBACK_CAPTURE_RESULT ", error, " ", image.get_width(), "x", image.get_height())
	await create_timer(1.0).timeout
	assert(site.find_children("*", "GPUParticles3D", true, false).is_empty(), "Burst did not clean up")
	quit()
