class_name PlayerMovementState

extends PlayerState

signal movement_started
signal movement_ended

static var state_name = "PlayerMovementState"


func _init(player_controller: PlayerController) -> void:
	super(player_controller)



func enter() -> void:
	movement_started.emit()
	player.movement_component.enable_movement(true)
	animated_sprite_2d.play_idle_animation()


func handle_input(_event: InputEvent):
	handle_animation(_event)
	handle_transition(_event)


func handle_animation(_event: InputEvent):
	if is_input_movement(_event):
		animated_sprite_2d.play_movement_animation()
	elif is_no_input_pressed():
		animated_sprite_2d.play_idle_animation()


func handle_transition(_event: InputEvent):
	if is_input_attack(_event) and !player.is_silenced:
		var attack_state = state_machine.states["PlayerAttackState"] as PlayerAttackState
		if (attack_state.on_cooldown):
			return

		attack_state.set_input(_event)
		state_machine.transition(PlayerAttackState.state_name)
	elif is_input_parry(_event) and !player.is_silenced:
		var parry_state = state_machine.states["PlayerParryState"] as PlayerParryState
		if (parry_state.on_cooldown):
			return

		parry_state.set_input(_event)
		state_machine.transition(PlayerParryState.state_name)


func _on_stun_applied(duration: float):
	super(duration)
	state_machine.transition(PlayerStunState.state_name)


func exit() -> void:
	movement_ended.emit()
	player.movement_component.enable_movement(false)

func get_state_name() -> String:
	return state_name
