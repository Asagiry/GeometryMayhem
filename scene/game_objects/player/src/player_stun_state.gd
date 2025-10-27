class_name PlayerStunState

extends PlayerState

signal stun_started
signal stun_finished

var stun_duration:float

static var state_name = "PlayerStunState"


func set_duration(duration: float):
	stun_duration = duration


func enter() -> void:
	stun_started.emit()


func _process(delta: float) -> void:
	stun_duration-=delta
	if(stun_duration <= 0.0):
		player_state_machine.transition(PlayerIdleState.state_name)


func exit():
	stun_finished.emit()


func get_state_name() -> String:
	return state_name
