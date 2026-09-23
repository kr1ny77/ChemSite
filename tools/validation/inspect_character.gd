extends SceneTree
func _initialize() -> void:
	call_deferred("_inspect")

func _inspect() -> void:
	var scene := load("res://assets/models/character/chemist.glb") as PackedScene
	var instance := scene.instantiate()
	root.add_child(instance)
	for node in instance.find_children("*", "AnimationPlayer", true, false):
		print("ANIMATION_PLAYER ", node.get_path(), " ", node.get_animation_list())
	for node in instance.find_children("*", "Skeleton3D", true, false):
		print("SKELETON ", node.get_path(), " bones=", node.get_bone_count())
	quit()
