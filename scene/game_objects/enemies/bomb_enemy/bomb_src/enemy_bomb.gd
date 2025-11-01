class_name EnemyBombController

extends EnemyController


func _connect_signals():
	super._connect_signals()
	attack_controller.attack_finished.connect(_on_attack_finished)

func _start_state_machine():
	var states: Array[State] = [
		EnemyIdleState.new(self),
		EnemyBombAttackState.new(self),
		EnemyBackState.new(self),
		EnemyAggroState.new(self),
		EnemyStunState.new(self)
	]
	state_machine.start_machine(states)


func _on_attack_finished():
	queue_free()
