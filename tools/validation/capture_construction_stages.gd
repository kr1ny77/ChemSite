extends SceneTree
func _initialize() -> void:
 call_deferred("_run")
func _run() -> void:
 var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
 site.save_path="user://construction-capture-isolated.json"
 root.add_child(site)
 await process_frame
 site.get_window().focus_exited.disconnect(site._pause_on_focus_loss)
 site.set_process(false)
 site._player.set_physics_process(false)
 site.get_node("CameraRig/PlayerVisibility").set_process(false)
 for mesh in get_nodes_in_group("player_camera_occluder"):
  if mesh is MeshInstance3D: mesh.transparency=0.0
 site._wayfinder.show_station({},site._camera,false)
 site.get_node("CanvasLayer").visible=false
 var camera := site.get_node("CameraRig/Camera3D") as Camera3D
 var initial_position := camera.global_position
 var initial_rotation := camera.global_rotation
 var initial_size := camera.size
 var folder := "res://artifacts/construction-stages-native"
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
 for stage in range(6):
  site._construction_view.set_stage(stage)
  for close in range(2):
   if close==0:
    camera.global_position=initial_position
    camera.global_rotation=initial_rotation
    camera.size=initial_size
   else:
    var target := Vector3(-5.6,2.4,4.1)
    camera.global_position=target+Vector3(5,4.5,6)
    camera.look_at(target)
    camera.size=7.8
   await process_frame
   RenderingServer.force_draw()
   if root.get_texture().get_image().save_png(folder+"/stage-%d-%s.png" % [stage,"close" if close else "yard"]) != OK:
    push_error("Construction capture write failed")
    quit(1)
    return
 site.queue_free()
 await process_frame
 print("CHEMSITE_CONSTRUCTION_CAPTURE_OK")
 quit()
