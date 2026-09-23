extends SceneTree

const ROUTES := [
	{"station": "substance-storage", "steps": [["move_left", -6.0, "x"], ["move_forward", -1.7, "z"]]},
	{"station": "formula-board", "steps": [["move_forward", -3.4, "z"], ["move_right", 4.0, "x"]]},
	{"station": "periodic-table-terminal", "steps": [["move_back", 4.5, "z"], ["move_right", 3.7, "x"]]},
]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var site := (load("res://scenes/levels/construction_site.tscn") as PackedScene).instantiate()
	root.add_child(site)
	await physics_frame
	var player := site.get_node("Player") as CharacterBody3D
	for route in ROUTES:
		player.global_position = Vector3(0, 0.05, 0)
		player.velocity = Vector3.ZERO
		for step in route.steps:
			var action: String = step[0]
			var target: float = step[1]
			var axis: String = step[2]
			Input.action_press(action)
			var reached := false
			for frame in range(240):
				await physics_frame
				var current: float = player.global_position.x if axis == "x" else player.global_position.z
				if absf(current - target) < 0.15:
					reached = true
					break
			Input.action_release(action)
			assert(reached, "Route blocked toward %s at %s" % [route.station, action])
			for frame in range(18):
				await physics_frame
		site._find_nearest_station()
		assert(site._nearest_station.get("id", "") == route.station, "Station could not be reached: " + route.station)
	print("CHEMSITE_STATION_ROUTES_OK")
	quit()
