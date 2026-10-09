extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var count := 0
	var edge_checks := 0
	var offscreen_checks := 0
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
			for player_position in [Vector3.ZERO, Vector3(-9, 0, -7), Vector3(-9, 0, 7), Vector3(9, 0, -7), Vector3(9, 0, 7)]:
				site._camera_rig.global_position = player_position * Vector3(.6, 0, .6)
				for reduced in [false, true]:
					site._wayfinder.reduced_motion = reduced
					site._wayfinder._position_arrow()
					var marker: Control = site._wayfinder._arrow
					var viewport: Vector2 = root.get_visible_rect().size
					for corner in [Vector2.ZERO, Vector2(marker.size.x, 0), marker.size, Vector2(0, marker.size.y)]:
						var screen_corner: Vector2 = marker.get_global_transform() * corner
						if not Rect2(Vector2(0, 111), viewport - Vector2(0, 251)).has_point(screen_corner):
							push_error("Rotated station arrow leaves safe screen area")
							quit(1)
							return
					if site._wayfinder.offscreen_target:
						var target: Vector2 = site._camera.unproject_position(site._wayfinder.global_position)
						var center: Vector2 = marker.position + marker.size * .5
						var heading := Vector2.DOWN.rotated(marker.rotation)
						if heading.dot((target - center).normalized()) < .9999:
							push_error("Screen-edge arrow points away from station")
							quit(1)
							return
						offscreen_checks += 1
					elif not is_zero_approx(marker.rotation):
						push_error("Visible station arrow must point downward")
						quit(1)
						return
					edge_checks += 1
		site._hud.show_pause()
		site._update_wayfinder()
		assert(not site._wayfinder._arrow.visible, "Modal HUD must hide arrow independently of controls")
		site._hud.close_panel()
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
	if edge_checks != 2000 or offscreen_checks == 0:
		push_error("Station edge coverage missing")
		quit(1)
		return
	print("STATION_WAYFINDER_SMOKE_OK tasks=", count, " edge_checks=", edge_checks, " offscreen_checks=", offscreen_checks)
	quit()
