extends SceneTree
const PROGRESS = preload("res://scripts/core/construction_progress.gd")
const SAVE = preload("res://scripts/core/save_data.gd")
const VIEW = preload("res://scripts/world/construction_stage_view.gd")
const PATH := "user://construction-progress-smoke.json"
func _initialize() -> void:
 call_deferred("_run")
func _run() -> void:
 assert(PROGRESS.stage_from_progress({}) == 0)
 assert(PROGRESS.stage_from_progress({"best_stars":2}) == 1)
 assert(PROGRESS.stage_from_progress({"level_records":false}) == 0)
 assert(PROGRESS.stage_from_progress({"best_stars":3,"level_records":{"2":{"best_stars":3}}}) == 0)
 assert(PROGRESS.stage_from_progress({"level_records":{"1":{"best_stars":1},"3":{"best_stars":3}}}) == 1)
 assert(PROGRESS.stage_from_progress({"level_records":{"1":false}}) == 0)
 DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
 var model := (load(PROGRESS.DEFINITION.model_path) as PackedScene).instantiate() as Node3D
 root.add_child(model)
 var view := VIEW.new()
 root.add_child(view)
 view.configure(model, 0)
 for stage in range(6):
  if stage > 0:
   assert(SAVE.record_round(700,5,PATH,stage) == OK)
  assert(PROGRESS.stage_from_progress(SAVE.load_progress(PATH)) == stage)
  view.set_stage(stage)
  for index in range(6):
   assert((model.find_child("Stage%d" % index,true,false) as Node3D).visible == (index <= stage))
  assert((model.find_child("TemporaryRearRail",true,false) as Node3D).visible == (stage < 3))
  assert((model.find_child("TemporaryFormwork",true,false) as Node3D).visible == (stage < 2))
  assert(SAVE.record_round(0,0,PATH,maxi(stage,1)) == OK)
  assert(PROGRESS.stage_from_progress(SAVE.load_progress(PATH)) == stage)
 view.configure(model,5)
 assert(view._parts.size()==6)
 var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
 site.save_path=PATH
 root.add_child(site)
 await process_frame
 assert(site._construction_stage==5 and site._construction_view.stage==5)
 site.mode="practice"
 site._completed=5
 site._score=700
 var before := FileAccess.get_file_as_string(PATH)
 site._finish_round()
 assert(FileAccess.get_file_as_string(PATH)==before)
 site.queue_free()
 await process_frame
 model.queue_free()
 view.queue_free()
 DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
 await process_frame
 print("CHEMSITE_CONSTRUCTION_PROGRESS_OK")
 quit()
