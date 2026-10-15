extends SceneTree
const COURSE = preload("res://scripts/chemistry/course_catalog.gd")
const SITE = preload("res://scenes/levels/construction_site.tscn")
const SAVE = preload("res://scripts/core/save_data.gd")
const PATH = "user://qa_course_integration_isolated.json"
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	var ids := {}
	for chapter in COURSE.chapters():
		var tasks := COURSE.tasks(int(chapter.id))
		assert(not tasks.is_empty())
		var site := SITE.instantiate()
		site.level = int(chapter.environment)
		site.course_chapter = int(chapter.id)
		site.save_path = PATH
		site._load_tasks()
		var stations: Array = []
		for station in site._stations(): stations.append(station.id)
		for task in site._tasks:
			assert(task.station in stations, "Missing station: " + task.id + " " + task.station)
			assert(not ids.has(task.id))
			ids[task.id] = true
		site.free()
	assert(ids.size() == 1000)
	DirAccess.remove_absolute(PATH)
	var chapter_tasks := COURSE.tasks(1)
	for index in range(2):
		assert(SAVE.record_answer(chapter_tasks[index], true, PATH, 1) == OK)
	assert(SAVE.record_chapter(1, 2, 200, PATH) == OK)
	assert(SAVE.load_progress(PATH).unlocked_chapter == 1)
	for index in range(2, 5):
		assert(SAVE.record_answer(chapter_tasks[index], true, PATH, 1) == OK)
	assert(SAVE.record_chapter(1, 3, 300, PATH) == OK)
	assert(SAVE.load_progress(PATH).unlocked_chapter == 2)
	var practice := SITE.instantiate()
	practice.mode = "practice"
	practice.level = 5
	practice.practice_topics = ["Строение атома", "Химия цемента"]
	practice._load_tasks()
	var found := {}
	for task in practice._tasks:
		assert(task.topic in practice.practice_topics)
		assert(task.station == "inspection-station")
		found[task.topic] = true
	assert(found.size() == 2)
	assert(practice._tasks[0].topic != practice._tasks[1].topic)
	practice.free()
	DirAccess.remove_absolute(PATH)
	print("COURSE_INTEGRATION_OK 13 chapters, 1000 unique tasks, station routing, progression, multi-topic practice")
	quit()
