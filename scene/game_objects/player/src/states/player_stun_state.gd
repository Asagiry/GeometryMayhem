class_name PlayerStunState

extends PlayerState

signal stun_started
signal stun_finished

static var state_name = "PlayerStunState"

var stun_duration:float

func set_duration(duration: float):
	stun_duration = duration


func enter() -> void:
	stun_started.emit()


func process(delta: float) -> void:
	stun_duration-=delta
	player.move_and_collide(Vector2.ZERO)
	if(stun_duration <= 0.0):
		player_state_machine.transition(PlayerIdleState.state_name)


func exit():
	stun_finished.emit()
	player.is_stunned = false


func get_state_name() -> String:
	return state_name
