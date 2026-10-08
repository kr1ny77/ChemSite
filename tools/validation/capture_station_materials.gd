extends SceneTree
func _initialize() -> void:
 call_deferred("_run")
func _run() -> void:
 var folder := "res://artifacts/station-materials-" + ("compatibility" if OS.get_cmdline_user_args().has("--compatibility-review") else ("after" if OS.get_cmdline_user_args().has("--after") else "before"))
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
 var seen := {}
 for level in range(1,6):
  var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
  site.level=level
  site.save_path="user://station-material-capture-isolated.json"
  root.add_child(site)
  await process_frame
  for frame in range(20): await process_frame
  site.set_process(false)
  site.get_node("CanvasLayer").visible=false
  site.get_node("CameraRig").set_process(false)
  var camera := site.get_node("CameraRig/Camera3D") as Camera3D
  for station in site._stations():
   if seen.has(station.model): continue
   seen[station.model]=true
   var target:Vector3=station.position+Vector3(0,1.2,0)
   camera.size=3.7
   for side in range(2):
    camera.global_position=target+Vector3(3 if side==0 else -3,2.4,4)
    camera.look_at(target)
    await process_frame
    RenderingServer.force_draw(false)
    assert(root.get_texture().get_image().save_png(folder+"/%s-%d.png" % [station.model,side])==OK)
  site.queue_free()
  await process_frame
 print("CHEMSITE_STATION_MATERIAL_CAPTURE_OK %d" % seen.size())
 quit()
