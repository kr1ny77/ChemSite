extends SceneTree

const BANK = preload("res://scripts/chemistry/task_bank.gd")
const EXPECTED := {"L3-101": [3.0], "L3-102": [7.0], "L3-103": [11.0], "L3-107": [2.0, 4.0]}

func _initialize() -> void:
	call_deferred("_run")
	create_timer(15.0).timeout.connect(func(): quit(1))

func _run() -> void:
	var hud := (load("res://scenes/ui/game_hud.tscn") as PackedScene).instantiate()
	root.add_child(hud)
	var cases := 0
	for viewport_size in [Vector2i(1028, 642), Vector2i(1152, 720), Vector2i(1440, 900)]:
		root.size = viewport_size
		for static_motion in [false, true]:
			hud.reduced_motion = static_motion
			for task in BANK.load_verified_tasks(3):
				if not EXPECTED.has(task.id):
					continue
				hud.show_task(task, str(task.station))
				var meter: VBoxContainer = hud._ph_view
				for index in range(task.parameters.phSamples.size()):
					assert(not meter._readouts.get_child(index).visible, "Reading revealed before measurement")
					meter.read_sample(index)
					var panel: PanelContainer = meter._readouts.get_child(index)
					var scale: Control = panel.get_child(0).get_node("MeasurementScale")
					assert(scale.value == EXPECTED[task.id][index])
					assert(absf(scale.marker_fraction() - EXPECTED[task.id][index] / 14.0) < .00001)
					assert(scale.is_processing() != static_motion)
					if not static_motion:
						scale._process(.4)
						assert(not scale.is_processing(), "Measurement feedback never settles")
				for frame in range(3):
					await process_frame
				var rect: Rect2 = hud._panel.get_global_rect()
				assert(rect.end.y <= root.get_visible_rect().size.y + 1)
				assert(hud._panel.get_combined_minimum_size().y <= hud._panel.size.y + 1)
				for panel in meter._readouts.get_children():
					assert(rect.encloses(panel.get_global_rect()), "Meter card exceeds task panel")
				assert(hud._panel_content.get_children().back().get_global_rect().end.y <= rect.end.y - 5)
				cases += 1
	print("PH_SCALE_SMOKE_OK cases=", cases)
	quit()
