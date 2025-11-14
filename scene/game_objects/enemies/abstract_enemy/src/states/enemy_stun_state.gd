class_name EnemyStunState

extends EnemyState

signal stun_started
signal stun_finished

static var state_name = "EnemyStunState"

var stun_duration: float = 1.0

func set_duration(duration: float):
	stun_duration = duration


func enter() -> void:
	stun_started.emit()
	enemy.animated_sprite_2d.stop()


func physics_process(delta: float) -> void:
	stun_duration-=delta
	enemy.move_and_collide(Vector2.ZERO)
	if stun_duration <= 0.0 or !enemy.is_stunned:
		state_machine.transition(EnemyIdleState.state_name)


func exit():
	stun_finished.emit()
	enemy.is_stunned = false
	enemy.animated_sprite_2d.play("idle")


func get_state_name() -> String:
	return state_name
