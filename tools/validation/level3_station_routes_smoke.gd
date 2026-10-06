extends SceneTree

const ROUTES := [
	{"station": "solution-laboratory", "steps": [["move_left", -3.3, "x"], ["move_forward", -1.7, "z"]]},
	{"station": "ionic-reaction-station", "steps": [["move_forward", -3.4, "z"], ["move_right", 4.35, "x"]]},
	{"station": "inspection-station", "steps": [["move_back", 4.5, "z"], ["move_right", 4.0, "x"]]},
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	site.level = 3
	root.add_child(site)
	await physics_frame
	var player := site.get_node("Player") as CharacterBody3D
	for route in ROUTES:
		player.global_position = Vector3(0, 0.05, 0)
		player.velocity = Vector3.ZERO
		for step in route.steps:
			Input.action_press(step[0])
			var reached := false
			for frame in range(240):
				await physics_frame
				var current: float = player.global_position.x if step[2] == "x" else player.global_position.z
				if absf(current - float(step[1])) < 0.15:
					reached = true
					break
			Input.action_release(step[0])
			if not reached:
				push_error("Route blocked toward %s at %s" % [route.station, step[0]])
				quit(1)
				return
			for frame in range(18):
				await physics_frame
		site._find_nearest_station()
		if site._nearest_station.get("id", "") != route.station:
			push_error("Station unreachable: " + route.station)
			quit(1)
			return
	print("CHEMSITE_LEVEL3_STATION_ROUTES_OK")
	quit()
