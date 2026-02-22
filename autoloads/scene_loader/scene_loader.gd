extends Node

signal progress_changed(value: float)
signal load_finished


var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true

func _ready():
	# Disable processing until a load is requested [00:01:39]
	set_process(false)

func load_scene(_scene_path: String) -> void:
	scene_path = _scene_path
	
	# Instantiate and add the loading screen [00:02:00]
	var new_loading_screen = GlobalData.UI_LOADING_SCENE.instantiate()
	add_child(new_loading_screen)
	
	# Connect signals to the loading screen [00:02:12]
	progress_changed.connect(new_loading_screen.on_progress_changed)
	load_finished.connect(new_loading_screen.on_load_finished)
	
	# Wait for the loading screen's fade-in animation to finish [00:02:40]
	await new_loading_screen.loading_screen_ready
	start_load()

func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)

func _process(_delta):
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	
	# Emit progress (progress[0] is a float from 0 to 1) [00:04:26]
	progress_changed.emit(progress[0])
	
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			get_tree().change_scene_to_packed(loaded_resource)
			load_finished.emit()
			set_process(false)