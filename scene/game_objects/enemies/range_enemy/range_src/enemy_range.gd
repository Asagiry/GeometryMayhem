class_name EnemyRangeController

extends EnemyController


func _start_state_machine():
	var states: Array[State] = [
		EnemyIdleState.new(self),
		EnemyRangeAttackState.new(self),
		EnemyBackState.new(self),
		EnemyAggroState.new(self),
		EnemyStunState.new(self)
	]
	state_machine.start_machine(states)
