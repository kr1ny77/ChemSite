extends RefCounted

static func run(main: Node, capture_visual: bool = false) -> bool:
	main.start_game("career", "", 1)
	var site: Node3D = main._current
	await main.get_tree().process_frame
	var player: CharacterBody3D = site.get_node("Player")
	var hud: Control = site.get_node("CanvasLayer/GameHud")
	var interact := InputEventAction.new()
	interact.action = "interact"
	interact.pressed = true
	if site._site_inspections.size() != 8:
		push_error("Packaged site inspection data missing")
		return false
	if capture_visual:
		var error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://qa-site-inspections"))
		if error != OK:
			push_error("Could not create packaged inspection capture directory")
			return false
	for entry in site._site_inspections:
		player.global_position = entry.position + Vector3(0, 0.05, 0)
		player.velocity = Vector3.ZERO
		site._find_nearest_station()
		if site._nearest_inspection.get("id", "") != entry.id:
			push_error("Packaged site inspection unavailable: " + str(entry.id))
			return false
		site._unhandled_input(interact)
		if not hud.is_panel_open() or player.controls_enabled or site._completed != 0:
			push_error("Packaged site inspection failed: " + str(entry.id))
			return false
		if capture_visual and entry.id == "construction_shell":
			for frame in range(5):
				await main.get_tree().process_frame
			await RenderingServer.frame_post_draw
			var image := main.get_viewport().get_texture().get_image()
			if image.save_png("user://qa-site-inspections/concrete-frame.png") != OK:
				push_error("Could not capture packaged site inspection")
				return false
		site._resume()
		if hud.is_panel_open() or not player.controls_enabled:
			push_error("Packaged site inspection did not close: " + str(entry.id))
			return false
	if capture_visual:
		site.queue_free()
		await main.get_tree().process_frame
		(main.get_node("AudioController") as Node).queue_free()
		await main.get_tree().process_frame
		await main.get_tree().create_timer(0.2).timeout
	print("CHEMSITE_EXPORT_SITE_INSPECTIONS_OK")
	return true
