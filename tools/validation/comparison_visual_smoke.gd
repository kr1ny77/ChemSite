extends SceneTree

const BANK = preload("res://scripts/chemistry/task_bank.gd")
const EXPECTED := {"L4-133": ["thermal-low", "thermal-high"], "L4-143": ["thermal-reference", "thermal-high"], "L4-144": ["thermal-reference", "thermal-low"], "L4-155": ["intact-coating", "damaged-coating"], "L4-157": ["bare-surface", "passive-film"], "L4-158": ["dry-surface", "electrolyte-film"]}

func _initialize() -> void:
	call_deferred("_run")
	create_timer(20.0).timeout.connect(func(): quit(1))

func _run() -> void:
	var hud := (load("res://scenes/ui/game_hud.tscn") as PackedScene).instantiate()
	root.add_child(hud)
	var tasks: Array[Dictionary] = BANK.load_verified_tasks(4).filter(func(task): return task.get("parameters", {}).has("comparisonVisuals"))
	if not _check(tasks.size() == 12, "Expected six electrodes, three corrosion and three thermal comparisons"): return
	var cases := 0
	for viewport_size in [Vector2i(1028, 642), Vector2i(1152, 720), Vector2i(1440, 900)]:
		root.size = viewport_size
		for static_motion in [false, true]:
			hud.reduced_motion = static_motion
			for task in tasks:
				if task.interactionType == "electrochemistry":
					for index in range(2):
						if not _check(task.parameters.comparisonVisuals[index].caption == str(task.parameters.comparisonRuns[index].observation).get_slice(";", 0), task.id + " schematic half-equation differs from curated readout"): return
				if task.id in ["L4-133", "L4-143", "L4-144"]:
					for index in range(2):
						if not _check(task.parameters.comparisonVisuals[index].caption == task.parameters.comparisonRuns[index].setting, task.id + " thermal caption differs from curated setting"): return
				hud.show_task(task, task.station)
				var comparison: VBoxContainer = hud._comparison_view
				var visual: Control = comparison.get_node("ObservationVisual")
				var expected: Array = EXPECTED.get(task.id, ["metal-oxidation", "metal-reduction"])
				if not _check(visual.kinds == expected and visual.reduced_motion == static_motion, task.id + " visual mapping"): return
				if not _check(not visual.visible and not visual.is_processing() and not comparison.is_complete(), task.id + " premature observation"): return
				var completed := [0]
				comparison.comparison_completed.connect(func(): completed[0] += 1)
				comparison.inspect_run(1)
				if not _check(visual.visible and visual.observed == [false, true] and not comparison.is_complete(), task.id + " partial reveal"): return
				comparison.inspect_run(1)
				if not _check(completed[0] == 0, task.id + " repeated probe unlocked answers"): return
				comparison.inspect_run(0)
				if not _check(comparison.is_complete() and completed[0] == 1 and visual.observed == [true, true], task.id + " completion gate"): return
				if not _check(visual.is_processing() != static_motion, task.id + " motion mode"): return
				if not static_motion: visual._process(1.3)
				if not _check(not visual.is_processing(), task.id + " animation never settles"): return
				for frame in range(3): await process_frame
				if not _check(hud._panel.get_global_rect().encloses(visual.get_global_rect()), task.id + " diagram outside panel"): return
				if not _check(hud._panel.get_combined_minimum_size().y <= hud._panel.size.y + 1, task.id + " content overflow"): return
				cases += 1
	hud.queue_free()
	await process_frame
	print("COMPARISON_VISUAL_SMOKE_OK cases=", cases)
	quit()

func _check(condition: bool, message: String) -> bool:
	if not condition:
		push_error(message)
		quit(1)
	return condition
