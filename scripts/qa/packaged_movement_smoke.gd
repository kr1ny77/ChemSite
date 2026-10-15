extends RefCounted

# Built-in exported movement gate; creates its own floor/player and writes no saves.
var final_length_error := 0.0
var steps := 0

func run(main: Node) -> bool:
	var tree := main.get_tree()
	var root := tree.root
	Engine.physics_ticks_per_second = 60
	var version := str(ProjectSettings.get_setting("application/config/version"))
	var floor_body := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(100, 0.2, 100)
	collider.shape = box
	floor_body.add_child(collider)
	floor_body.position.y = -0.1
	root.add_child(floor_body)
	var player := (load("res://scenes/player/player.tscn") as PackedScene).instantiate() as CharacterBody3D
	root.add_child(player)
	player.position.y = 0.04
	player.footstep.connect(func(): steps += 1)
	var skeleton := player.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
	skeleton.skeleton_updated.connect(func():
		for side in ["l", "r"]:
			var hip := skeleton.get_bone_global_pose(skeleton.find_bone("thigh_" + side)).origin
			var knee := skeleton.get_bone_global_pose(skeleton.find_bone("calf_" + side)).origin
			var ankle := skeleton.get_bone_global_pose(skeleton.find_bone("foot_" + side)).origin
			final_length_error = maxf(final_length_error, maxf(absf(hip.distance_to(knee) - 0.15), absf(knee.distance_to(ankle) - 0.14)))
	)
	var action := "move_right"
	player.visual.rotation.y = PI / 2.0
	Input.action_press(action)
	var distance := 0.0
	var before := player.position
	for tick in range(150):
		if tick == 45 or tick == 90:
			Input.action_release(action)
			action = "move_forward" if tick == 45 else "move_back"
			Input.action_press(action)
		await tree.physics_frame
		await tree.process_frame
		distance += Vector2(player.position.x - before.x, player.position.z - before.z).length()
		before = player.position
		if tick > 15: assert(player.is_on_floor())
		if tick == 35: assert(Vector2(player.velocity.x, player.velocity.z).length() > 3.4)
	Input.action_release(action)
	player.controls_enabled = false
	var before_steps := steps
	for tick in range(30):
		await tree.physics_frame
		await tree.process_frame
	assert(Vector2(player.velocity.x, player.velocity.z).length() < 0.001)
	assert(steps == before_steps and steps > 2)
	assert(distance > 6.0 and distance < 10.0)
	assert(final_length_error < 0.0001)
	var plant: SkeletonModifier3D = player._foot_plant
	assert(plant.maximum_pelvis_offset < 0.06501 and plant.maximum_pelvis_step < 0.02501)
	assert(plant.pelvis_offset.length() < 0.001 and absf(plant.pelvis_offset.y) < 0.000001)
	print("PACKAGED_MOVEMENT_SMOKE_OK version=", version, " distance_m=", distance, " steps=", steps, " final_leg_error_m=", final_length_error)
	return true
