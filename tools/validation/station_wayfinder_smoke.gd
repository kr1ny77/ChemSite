extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var count := 0
	for level in range(1, 6):
		var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
		site.level = level
		root.add_child(site)
		site.set_process(false)
		for index in range(site._tasks.size()):
			site._task_index = index
			site._update_wayfinder()
			if site._wayfinder.target_station_id != site._tasks[index].station or not site._wayfinder._ring.visible:
				push_error("Target marker differs from current chemistry station")
				quit(1)
				return
			count += 1
		site._player.controls_enabled = false
		site._update_wayfinder()
		if site._wayfinder._arrow.visible or site._wayfinder._ring.visible:
			push_error("Marker remains visible beneath modal interaction")
			quit(1)
			return
		site._player.controls_enabled = true
		site._wayfinder.reduced_motion = true
		site._update_wayfinder()
		var before: Vector2 = site._wayfinder._arrow.position
		site._wayfinder._process(.2)
		if not before.is_equal_approx(site._wayfinder._arrow.position):
			push_error("Reduced-motion marker moved")
			quit(1)
			return
		site.queue_free()
		await process_frame
	if count != 200:
		push_error("Wayfinder gate requires all 200 curated tasks")
		quit(1)
		return
	print("STATION_WAYFINDER_SMOKE_OK tasks=", count)
	quit()
