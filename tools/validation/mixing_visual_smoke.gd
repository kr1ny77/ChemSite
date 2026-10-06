extends SceneTree

const BANK = preload("res://scripts/chemistry/task_bank.gd")
const EXPECTED := {"L2-051": ["precipitate", "f8f7ed"], "L2-052": ["precipitate", "f8f7ed"], "L2-053": ["precipitate", "62b4d9"], "L2-054": ["precipitate", "9b5935"], "L2-055": ["gas", "ffffff"]}

func _initialize() -> void:
	call_deferred("_run")
	create_timer(15.0).timeout.connect(func(): quit(1))

func _run() -> void:
	var hud := (load("res://scenes/ui/game_hud.tscn") as PackedScene).instantiate()
	root.add_child(hud)
	var count := 0
	for viewport_size in [Vector2i(1028, 642), Vector2i(1152, 720), Vector2i(1440, 900)]:
		root.size = viewport_size
		for static_motion in [false, true]:
			hud.reduced_motion = static_motion
			for task in BANK.load_verified_tasks(2):
				if not EXPECTED.has(task.id):
					continue
				hud.show_task(task, str(task.station))
				var mix: VBoxContainer = hud._mix_view
				assert(not mix.has_node("ObservationVisual"), "Visual reveals observation before selecting samples")
				for reagent in task.parameters.mixingReagents:
					mix._select(reagent)
				assert(mix.is_mixed())
				var view: Control = mix.get_node("ObservationVisual")
				assert(view.effect_kind == EXPECTED[task.id][0])
				assert(view.effect_color == Color(EXPECTED[task.id][1]))
				assert(view.reduced_motion == static_motion)
				assert(view.is_processing() != static_motion)
				if not static_motion:
					view._process(1.3)
					assert(not view.is_processing(), "Observation animation never settles")
				for frame in range(3):
					await process_frame
				assert(hud._panel.get_global_rect().encloses(view.get_global_rect()), "Observation exceeds panel bounds")
				count += 1
	print("MIXING_VISUAL_SMOKE_OK cases=", count)
	quit()
