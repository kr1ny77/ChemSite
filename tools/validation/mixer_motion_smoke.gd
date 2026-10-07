extends SceneTree
const MOTION = preload("res://scripts/world/site_mixer_motion.gd")
func _initialize() -> void:
 call_deferred("_run")
func _check(ok: bool, message: String) -> bool:
 if not ok:
  push_error(message)
  quit(1)
 return ok
func _run() -> void:
 var prop := (load("res://assets/models/environment/site_mixer.glb") as PackedScene).instantiate() as Node3D
 root.add_child(prop)
 var motion := MOTION.new()
 root.add_child(motion)
 motion.configure(prop, false)
 var animation := prop.get_node("AnimationPlayer") as AnimationPlayer
 animation.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
 var rotor := prop.get_node("Drum axis/Drum rotor") as Node3D
 var axis := rotor.get_parent() as Node3D
 var fixed := prop.get_node("front cross member") as Node3D
 var fixed_transform := fixed.global_transform
 var initial := rotor.global_transform
 var sample := (rotor.get_child(0) as MeshInstance3D).mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX][0] as Vector3
 var sample_node := rotor.get_child(0) as MeshInstance3D
 var reference := axis.global_transform.affine_inverse() * (sample_node.global_transform * sample)
 motion.set_running(true)
 for index in range(80):
  animation.advance(animation.get_animation("DrumRotate").length / 80.0)
  var point := axis.global_transform.affine_inverse() * (sample_node.global_transform * sample)
  if not _check(absf(point.y-reference.y)<0.00001 and absf(Vector2(point.x,point.z).length()-Vector2(reference.x,reference.z).length())<0.00001,"Mixer exported axis drift"):
   return
  if not _check(fixed.global_transform.is_equal_approx(fixed_transform),"Mixer chassis moved"):
   return
 if not _check(rotor.global_transform.is_equal_approx(initial),"Mixer full-cycle seam"):
  return
 animation.advance(2.0)
 motion.set_running(false)
 var paused := animation.current_animation_position
 for frame in range(3):
  await process_frame
 if not _check(is_equal_approx(animation.current_animation_position,paused) and not animation.is_playing(),"Mixer pause changed phase"):
  return
 motion.set_running(true)
 if not _check(is_equal_approx(animation.current_animation_position,paused) and animation.is_playing(),"Mixer resume reset phase"):
  return
 motion.configure(prop,true)
 motion.set_running(true)
 if not _check(not animation.is_playing() and rotor.global_transform.is_equal_approx(initial),"Reduced-motion mixer moved"):
  return
 prop.queue_free()
 motion.queue_free()
 await process_frame
 var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
 root.add_child(site)
 await process_frame
 site.set_process(false)
 site._machinery_player.play()
 await physics_frame
 await process_frame
 var site_motion: Node = site._mixer_motion
 if not _check(site_motion != null,"World mixer controller missing"):
  return
 site._process(0.0)
 var site_animation: AnimationPlayer = site_motion._animation
 if not site.reduced_motion and not _check(site_animation.is_playing(),"Exploration mixer stopped"):
  return
 site.get_node("Player").controls_enabled=false
 site._process(0.0)
 if not _check(not site_animation.is_playing() and site._machinery_player.stream_paused,"Disabled controls failed to pause mixer/audio"):
  return
 site.get_node("Player").controls_enabled=true
 site._round_done=true
 site._process(0.0)
 if not _check(not site_animation.is_playing(),"Results failed to pause mixer"):
  return
 site.queue_free()
 await process_frame
 await create_timer(0.8).timeout
 print("CHEMSITE_MIXER_MOTION_OK 80 axis samples; loop; pause/resume; reduced motion")
 quit()
