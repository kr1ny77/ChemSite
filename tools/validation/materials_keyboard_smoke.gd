extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _key(code: Key, shift := false) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.shift_pressed = shift
	event.pressed = true
	Input.parse_input_event(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await process_frame
func _run() -> void:
	root.size = Vector2i(1028,642)
	root.content_scale_size = Vector2i(1440,900)
	var hud := preload("res://scenes/ui/game_hud.tscn").instantiate()
	root.add_child(hud)
	var overlay := preload("res://scripts/ui/learning_materials.gd").new()
	overlay.initial_material = "organic"
	hud.add_child(overlay)
	await process_frame
	await process_frame
	assert(overlay._scroll.scroll_vertical == 0)
	await _key(KEY_PAGEDOWN)
	assert(overlay._scroll.scroll_vertical > 0, "Page Down did not scroll reference")
	await _key(KEY_PAGEUP)
	assert(overlay._scroll.scroll_vertical == 0, "Page Up did not return")
	await _key(KEY_END)
	assert(overlay._scroll.scroll_vertical > 0, "End did not scroll")
	await _key(KEY_HOME)
	assert(overlay._scroll.scroll_vertical == 0, "Home did not return")
	await _key(KEY_END)
	var selector: OptionButton = overlay.find_children("*", "OptionButton", true, false)[0]
	selector.select(11)
	selector.item_selected.emit(11)
	await process_frame
	assert(overlay._scroll.scroll_vertical == 0, "Material switch retained stale scroll")
	selector.select(0)
	selector.item_selected.emit(0)
	await process_frame
	var zoom: HSlider = overlay.find_children("*", "HSlider", true, false)[0]
	zoom.value = 2.0
	await process_frame
	await process_frame
	await _key(KEY_PAGEDOWN, true)
	assert(overlay._scroll.scroll_horizontal > 0, "Shift Page Down did not pan zoomed table")
	await _key(KEY_PAGEUP, true)
	assert(overlay._scroll.scroll_horizontal == 0, "Shift Page Up did not return")
	hud.queue_free()
	await process_frame
	print("MATERIALS_KEYBOARD_OK PageUp/PageDown/Home/End, selection resets scroll, shifted horizontal panning")
	quit()
