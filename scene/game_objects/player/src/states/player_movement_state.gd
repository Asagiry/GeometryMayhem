class_name PlayerMovementState

extends PlayerState

signal movement_started()
signal movement_ended()

static var state_name = "PlayerMovementState"

func enter() -> void:
	movement_started.emit()
	animated_sprite_2d.play("run")


func process(delta: float) -> void:
	if player.is_stunned:
			player_state_machine.transition(PlayerStunState.state_name)

	player.movement_component.handle_movement(delta)

	if player.movement_component.get_movement_vector().normalized() == Vector2.ZERO:
		player_state_machine.transition(PlayerIdleState.state_name)

func input(_event: InputEvent) -> void:
	if player.is_input_blocked:
		return

	if _event.is_action_pressed("left_mouse_click_dash") \
	and not player.player_attack_controller.is_on_cooldown:
		player.dash_from_mouse = true
		player_state_machine.transition(PlayerDashState.state_name)
	elif _event.is_action_pressed("shift_dash") \
	and not player.player_attack_controller.is_on_cooldown:
		player.dash_from_mouse = false
		player_state_machine.transition(PlayerDashState.state_name)
	elif _event.is_action_pressed("right_mouse_click_parry") \
	and not player.parry_controller.is_on_cooldown:
		player.parry_from_mouse = true
		player_state_machine.transition(PlayerParryState.state_name)
	elif _event.is_action_pressed("space_parry") \
	and not player.parry_controller.is_on_cooldown:
		player.parry_from_mouse = false
		player_state_machine.transition(PlayerParryState.state_name)


func get_state_name() -> String:
	return state_name


func exit() -> void:
	movement_ended.emit()
