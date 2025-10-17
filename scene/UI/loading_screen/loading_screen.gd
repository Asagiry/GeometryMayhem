extends Control

@export var level_scene_path: String = "res://scene/level/level.tscn"
@export var transition_scene: PackedScene

var transition_screen_instance
var scene_load_status = 0
var progress = []
var level_scene: PackedScene

func _ready():
	transition_screen_instance = transition_scene.instantiate()
	transition_screen_instance.transitioned.connect(_on_transition_screen_transitioned)
	ResourceLoader.load_threaded_request(level_scene_path)
	
func _process(_delta):
	scene_load_status = ResourceLoader.load_threaded_get_status(level_scene_path, progress)
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		level_scene = ResourceLoader.load_threaded_get(level_scene_path)
		get_tree().root.add_child(transition_screen_instance)
		transition_screen_instance.transition()

func _on_transition_screen_transitioned():
	if not level_scene:
		return
	get_tree().change_scene_to_packed(level_scene)
	transition_screen_instance.queue_free()
