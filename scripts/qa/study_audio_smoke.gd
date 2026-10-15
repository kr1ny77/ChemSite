extends RefCounted
const BANK = preload("res://scripts/chemistry/task_bank.gd")
const PATH := "user://qa-study-audio-isolated.json"
static func _fail(message: String) -> bool:
	push_error("Study audio: " + message)
	return false
static func run(main: Node) -> bool:
	var tree := main.get_tree()
	var original_hash := FileAccess.get_sha256("user://progress.json")
	DirAccess.remove_absolute(PATH)
	var audio: Node = main.get_node("AudioController")
	if AudioServer.get_bus_send(AudioServer.get_bus_index("UI")) != "SFX": return _fail("UI bus bypasses effect volume")
	if audio._ui.bus != "UI" or audio._liquid.bus != "SFX": return _fail("Cue routing differs")
	main._current._practice_button.pressed.emit()
	if not audio._ui.playing: return _fail("Menu action produced no cue")
	main.start_game("career", "", 2, PATH)
	var site: Node = main._current
	var mix: Dictionary = BANK.load_verified_tasks(2).filter(func(t: Dictionary) -> bool: return t.id == "L2-051")[0]
	site._hud.show_task(mix, mix.station)
	var liquid_count := [0]
	site.liquid_used.connect(func() -> void: liquid_count[0] += 1)
	site._hud._mix_view._select(str(mix.parameters.mixingReagents[0]))
	if liquid_count[0] != 0: return _fail("Partial selection sounded like completed mixing")
	site._hud._mix_view._select(str(mix.parameters.mixingReagents[1]))
	if liquid_count[0] != 1 or not audio._liquid.playing: return _fail("Completed mix produced no cue")
	site._hud._mix_view._select(str(mix.parameters.mixingReagents[0]))
	if liquid_count[0] != 1: return _fail("Completed mixing repeated its cue")
	site._hud.close_panel()
	var combos: Array = []
	site.combo_reached.connect(func(streak: int) -> void: combos.append(streak))
	for index in range(5):
		var task: Dictionary = site._tasks[site._task_index]
		var answer: Variant = task.correctAnswer
		site._submit_answer(str(answer.value) if answer is Dictionary else str(answer))
		site._resume()
	if combos != [3, 5] or not audio._combo.playing: return _fail("Combo thresholds or playback differ")
	main.start_game("career", "", 1, PATH)
	site = main._current
	site.set_process(false)
	var warnings: Array = []
	site.timer_warning.connect(func(seconds: int) -> void: warnings.append(seconds))
	site._time_left = 61.0
	site._process(2.0)
	if warnings != [60] or not audio._warning.playing: return _fail("Missing sixty-second cue")
	site._process(1.0)
	site._player.controls_enabled = false
	site._process(50.0)
	if warnings != [60] or site._time_left != 58.0: return _fail("Paused timer produced a cue")
	site._player.controls_enabled = true
	site._process(43.0)
	if warnings != [60, 15]: return _fail("Missing fifteen-second cue")
	site.mode = "practice"
	site._process(2000.0)
	if warnings != [60, 15] or site._time_left != 15.0: return _fail("Practice timer produced a cue")
	site.mode = "career"
	site._process(2000.0)
	if warnings != [60, 15]: return _fail("Finished timer repeated warnings")
	var sfx := AudioServer.get_bus_index("SFX")
	var prior_gain := AudioServer.get_bus_volume_db(sfx)
	audio.apply_settings({"sfx_volume": 0.0, "music_volume": 0.0})
	if AudioServer.get_bus_volume_db(sfx) > -59.0: return _fail("Effects control failed to silence cues")
	AudioServer.set_bus_volume_db(sfx, prior_gain)
	if original_hash != FileAccess.get_sha256("user://progress.json"): return _fail("QA changed real progress")
	main.show_menu()
	audio.queue_free()
	for frame in range(5): await tree.process_frame
	await tree.create_timer(.6).timeout
	DirAccess.remove_absolute(PATH)
	print("STUDY_AUDIO_SMOKE_OK version=", ProjectSettings.get_setting("application/config/version"), " menu, mixing-once, combo 3/5, timer 60/15, pause/practice/end, SFX routing")
	return true
