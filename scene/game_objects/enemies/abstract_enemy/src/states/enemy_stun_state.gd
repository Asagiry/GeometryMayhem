class_name EnemyStunState

extends EnemyState

signal stun_started
signal stun_finished

static var state_name = "EnemyStunState"

var stun_duration:float = 1

func set_duration(duration: float):
	stun_duration = duration


func enter() -> void:
	stun_started.emit()


func process(delta: float) -> void:
	if enemy.is_stunned == false:
		state_machine.transition(PlayerMovementState.state_name)
	stun_duration-=delta
	enemy.move_and_collide(Vector2.ZERO)
	if(stun_duration <= 0.0):
		state_machine.transition(PlayerMovementState.state_name)


func exit():
	stun_finished.emit()
	enemy.is_stunned = false


func get_state_name() -> String:
	return state_name
