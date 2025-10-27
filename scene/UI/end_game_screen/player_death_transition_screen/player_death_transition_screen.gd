class_name DeathScreen

extends Control

@onready var color_rect: ColorRect = %ColorRect
@onready var ok_button: Button = %OkButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	color_rect.transition_complete.connect(_on_transition_complete)
	ok_button.disabled = true
	ok_button.visible = false
	print("Viewport disabled input:", get_viewport().is_input_disabled())
	print("Tree paused:", get_tree().paused)
	#var window_size = DisplayServer.window_get_size()
	#pivot_offset.x = window_size.x / 2
	#pivot_offset.y = window_size.y / 2


func _on_transition_complete():
	ok_button.disabled = false
	ok_button.visible = true
	animation_player.play("button_in")


func _on_ok_button_pressed() -> void:
	animation_player.play("button_out")
	get_tree().change_scene_to_file("res://scene/UI/end_game_screen/end_game_screen.tscn")
