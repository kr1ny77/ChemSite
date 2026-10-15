extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var audio := preload("res://scripts/core/audio_controller.gd").new()
	root.add_child(audio)
	audio._music.stop()
	audio.apply_settings({"music_volume":0.0, "sfx_volume":1.0})
	var capture := AudioEffectCapture.new()
	capture.buffer_length = 2.0
	AudioServer.add_bus_effect(0, capture)
	await create_timer(.2).timeout
	var reports: Array = []
	for cue in [["ui", audio.play_ui_action], ["liquid", audio.play_liquid], ["combo", audio.play_combo.bind(3)], ["timer", audio.play_timer_warning.bind(60)]]:
		capture.clear_buffer()
		cue[1].call()
		await create_timer(.65).timeout
		var samples := capture.get_buffer(capture.get_frames_available())
		var peak := 0.0
		var square := 0.0
		for sample in samples:
			peak = maxf(peak, maxf(absf(sample.x), absf(sample.y)))
			square += sample.length_squared()
		if samples.is_empty() or peak < .0001 or peak >= .2:
			push_error("Native study cue is silent or exceeds headroom: " + str(cue[0]))
			quit(1)
			return
		reports.append({"cue":cue[0],"frames":samples.size(),"mix_rate":AudioServer.get_mix_rate(),"peak_dbfs":linear_to_db(peak),"rms_dbfs":linear_to_db(sqrt(square / (samples.size() * 2)))})
	AudioServer.remove_bus_effect(0, 0)
	audio.queue_free()
	await process_frame
	var path := "res://artifacts/study-audio-native.json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(reports, "\t"))
	file.close()
	print("STUDY_AUDIO_NATIVE_PLAYBACK_OK captured four finite cues through native mixer")
	quit()
