extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	site.get_node("CanvasLayer").visible = false
	var camera := site.get_node("CameraRig/Camera3D") as Camera3D
	camera.position = Vector3(4.0, 5.0, 7.0)
	camera.look_at(Vector3(0, 1.0, 0), Vector3.UP)
	camera.size = 7.0
	var player := site.get_node("Player") as CharacterBody3D
	player.controls_enabled = false
	player.play_reaction(true)
	await create_timer(0.55).timeout
	var image := root.get_viewport().get_texture().get_image()
	var error := image.save_png("res://artifacts/godot-character-celebrate.png")
	print("CHARACTER_REACTION_CAPTURE_RESULT ", error, " ", image.get_width(), "x", image.get_height())
	quit()
