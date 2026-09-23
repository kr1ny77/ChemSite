extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	await physics_frame
	var player := site.get_node("Player") as CharacterBody3D
	Input.action_press("move_right")
	for i in range(200):
		await physics_frame
	Input.action_release("move_right")
	assert(player.global_position.x < 8.4, "Player passed through perimeter")
	player.global_position = Vector3(-7.7, 0.05, -3.0)
	player.velocity = Vector3.ZERO
	Input.action_press("move_back")
	for i in range(90):
		await physics_frame
	Input.action_release("move_back")
	assert(player.global_position.z < -2.2, "Player passed through storage frame")
	player.global_position = Vector3(0.0, 0.05, -3.8)
	player.velocity = Vector3.ZERO
	Input.action_press("move_forward")
	for i in range(90):
		await physics_frame
	Input.action_release("move_forward")
	assert(player.global_position.z > -4.5, "Player passed through site cabin")
	print("CHEMSITE_COLLISION_SMOKE_OK")
	quit()
