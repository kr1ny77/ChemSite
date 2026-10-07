extends SceneTree
func _initialize() -> void:
 call_deferred("_run")
func _run() -> void:
 var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
 root.add_child(site)
 await process_frame
 site.set_process(false)
 site.get_node("CanvasLayer").visible = false
 var camera := site.get_node("CameraRig/Camera3D") as Camera3D
 var target := Vector3(7.55,0.9,-1.35)
 camera.size=3.3
 camera.global_position=target+Vector3(3,2.8,4)
 if OS.get_cmdline_user_args().has("--side"):
  camera.global_position=target+Vector3(-4,1.6,0)
 camera.look_at(target)
 var motion: Node=site._mixer_motion
 var animation: AnimationPlayer=motion._animation
 animation.callback_mode_process=AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
 motion.set_running(true)
 var folder := "res://artifacts/mixer-native-side" if OS.get_cmdline_user_args().has("--side") else "res://artifacts/mixer-native"
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
 var movie := OS.get_cmdline_user_args().has("--movie")
 for index in range(1202 if movie else 5):
  animation.seek(fmod(index / 60.0, animation.get_animation("DrumRotate").length) if movie else animation.get_animation("DrumRotate").length * index / 4.0,true)
  await process_frame
  RenderingServer.force_draw(false)
  if movie:
   continue
  var result:=root.get_texture().get_image().save_png(folder+"/pose-%d.png" % index)
  if result!=OK:
   push_error("Mixer capture failed")
   quit(1)
   return
 site.queue_free()
 await process_frame
 print("CHEMSITE_MIXER_CAPTURE_OK")
 quit()
