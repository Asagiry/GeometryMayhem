class_name PlayerParryState

extends PlayerState

static var state_name = "PlayerParryState"

var parry_timer := 0.0

func enter() -> void:
	animated_sprite_2d.speed_scale = 1 / player.parry_controller.parry_duration
	animated_sprite_2d.play("block")
	player.parry_controller.start_cooldown()
	parry_timer = player.parry_controller.parry_duration
	player.parry_controller.activate_parry(player.parry_from_mouse)


func process(delta: float):
	parry_timer -= delta
	if parry_timer <= 0.0:
		if player.movement_component.get_movement_vector().normalized() == Vector2.ZERO:
			player_state_machine.transition(PlayerIdleState.state_name)
		else:
			player_state_machine.transition(PlayerMovementState.state_name)


func exit() -> void:
	animated_sprite_2d.speed_scale = 1


func get_state_name() -> String:
	return state_name
