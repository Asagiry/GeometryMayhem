extends CanvasLayer

@export var transition_scene: PackedScene
@export var main_menu_scene: PackedScene

var transition_screen_instance

func _ready():
	transition_screen_instance = transition_scene.instantiate()
	transition_screen_instance.transitioned.connect(_on_transition_screen_transitioned)


func _on_ok_button_pressed() -> void:
	get_tree().root.add_child(transition_screen_instance)
	transition_screen_instance.transition()


func _on_transition_screen_transitioned():
	get_tree().change_scene_to_packed(main_menu_scene)
	transition_screen_instance.queue_free()
