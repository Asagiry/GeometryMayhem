extends CanvasLayer


@export var transition_scene: PackedScene
@export var main_menu_scene: PackedScene

var transition_screen_instance
var is_closing = false
var settings_menu_scene = preload("res://scene/UI/settings_menu/settings_menu.tscn")

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var panel_container: PanelContainer = %PanelContainer

func _ready():
	panel_container.pivot_offset = panel_container.size / 2
	get_tree().paused = true
	animation_player.play("in")
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0.3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _input(event):
	if event.is_action_pressed("pause"):
		_close_pause_menu()

func _close_pause_menu():
	if is_closing:
		return

	is_closing = true

	animation_player.play_backwards("in")

	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ONE, 0)
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0.3)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	await tween.finished

	get_tree().paused = false
	queue_free()


func _on_main_menu_button_pressed() -> void:
	transition_screen_instance = transition_scene.instantiate()
	transition_screen_instance.transitioned.connect(_on_transition_screen_transitioned)
	add_child(transition_screen_instance)
	transition_screen_instance.transition()


func _on_transition_screen_transitioned():
	get_tree().paused = false
	get_tree().change_scene_to_packed(main_menu_scene)
	transition_screen_instance.queue_free()


func _on_resume_button_pressed() -> void:
	_close_pause_menu()


func _on_settings_button_pressed() -> void:
	add_child(settings_menu_scene.instantiate())
