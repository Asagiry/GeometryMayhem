class_name PlayerParryState

extends PlayerState

signal parry_started
signal parry_finished

static var state_name = "PlayerParryState"

var input_from_mouse: bool
var on_cooldown: bool = false

func enter() -> void:
	if not parry_controller.parry_started.is_connected(_on_parry_started):
		parry_controller.parry_started.connect(_on_parry_started)

	if not parry_controller.parry_finished.is_connected(_on_parry_finished):
		parry_controller.parry_finished.connect(_on_parry_finished)

	if not parry_controller.parry_cooldown_timeout.is_connected(_on_parry_cooldown_timeout):
		parry_controller.parry_cooldown_timeout.connect(_on_parry_cooldown_timeout)

	on_cooldown = true

	parry_started.emit()

	player.parry_controller.activate_parry(input_from_mouse)


func _on_parry_started():
	animated_sprite_2d.play_parry_animation()


func _on_parry_finished():
	if player.is_stunned:
		state_machine.transition(PlayerStunState.state_name)
	else:
		state_machine.transition(PlayerMovementState.state_name)


func _on_parry_cooldown_timeout():
	on_cooldown = false


func set_input(event):
	input_from_mouse = event.is_action_pressed("right_mouse_click_parry")


func exit() -> void:
	parry_finished.emit()


func get_state_name() -> String:
	return state_name
