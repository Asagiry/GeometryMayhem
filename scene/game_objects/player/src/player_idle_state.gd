class_name PlayerIdleState

extends PlayerState

static var state_name = "PlayerIdleState"

func enter() -> void:
	animated_sprite_2d.play("idle")


func process(delta: float) -> void:
	player.handle_movement(delta)

	if player.get_movement_vector().normalized() != Vector2.ZERO:
		main_state_machine.transition(PlayerMovementState.state_name)
	if Input.is_action_just_pressed("left_mouse_click_dash") and \
	!player.dash_attack_controller.is_on_cooldown:
		player.dash_from_mouse = true
		main_state_machine.transition(PlayerDashState.state_name)
	elif Input.is_action_just_pressed("shift_dash") and \
	!player.dash_attack_controller.is_on_cooldown:
		player.dash_from_mouse = false
		main_state_machine.transition(PlayerDashState.state_name)
	elif Input.is_action_just_pressed("right_mouse_click_parry") and \
	!player.parry_controller.is_on_cooldown:
		player.parry_from_mouse = true
		main_state_machine.transition(PlayerParryState.state_name)
	elif Input.is_action_just_pressed("space_parry") and \
	!player.parry_controller.is_on_cooldown:
		player.parry_from_mouse = false
		main_state_machine.transition(PlayerParryState.state_name)


func get_state_name() -> String:
	return state_name
