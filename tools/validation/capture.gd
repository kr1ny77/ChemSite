extends SceneTree

const SETTINGS = preload("res://scripts/core/settings_data.gd")
const REDUCED_SETTINGS_PATH := "user://capture-reduced-motion-settings.json"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene := load("res://scenes/levels/construction_site.tscn") as PackedScene
	var site := scene.instantiate()
	var reduced := OS.get_cmdline_user_args().has("--reduced-motion")
	if reduced:
		assert(SETTINGS.save_settings({"reduced_motion": true}, REDUCED_SETTINGS_PATH) == OK)
		site.settings_path = REDUCED_SETTINGS_PATH
	root.add_child(site)
	for i in range(12):
		await process_frame
	var image := root.get_viewport().get_texture().get_image()
	var error := image.save_png("res://artifacts/godot-site-reduced-motion.png" if reduced else "res://artifacts/godot-site.png")
	print("CAPTURE_RESULT ", error, " ", image.get_width(), "x", image.get_height())
	if reduced:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(REDUCED_SETTINGS_PATH))
	quit()
