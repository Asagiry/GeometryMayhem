class_name EnemyStateMachine

extends StateMachine

enum PlayerVisibility {
	AGGRO,
	ATTACK
}

var player: PlayerController
var enemy: EnemyController

var player_zones: Dictionary = {
	PlayerVisibility.ATTACK: false,
	PlayerVisibility.AGGRO: false
}

func start_machine(init_states: Array[State]) -> void:
	super(init_states)

	player = get_tree().get_first_node_in_group("player") as PlayerController
	enemy = owner as EnemyController

	enemy.attack_zone.monitorable = false
	enemy.aggro_zone.monitorable = false

	enemy.attack_zone.area_entered.connect(func(body):
		player_zones[PlayerVisibility.ATTACK] = true
		call_deferred("_on_update_enemy_state")
	)
	enemy.attack_zone.area_exited.connect(func(body):
		player_zones[PlayerVisibility.ATTACK] = false
		call_deferred("_on_update_enemy_state")
	)
	enemy.aggro_zone.area_entered.connect(func(body):
		player_zones[PlayerVisibility.AGGRO] = true
		call_deferred("_on_update_enemy_state")
	)
	enemy.aggro_zone.area_exited.connect(func(body):
		player_zones[PlayerVisibility.AGGRO] = false
		call_deferred("_on_update_enemy_state")
	)


func _on_update_enemy_state():
	if is_log_enabled:
		print("[%s]: Current state \"%s\"" % [_parent_node_name, current_state.get_state_name()])

	if enemy.is_stunned:
		return

	var current_state_name = current_state.get_state_name()

	if player_zones[PlayerVisibility.ATTACK]:
		if current_state_name !=EnemyAttackState.state_name:
			transition(EnemyAttackState.state_name)

	elif player_zones[PlayerVisibility.AGGRO]:
		if current_state_name != EnemyAggroState.state_name:
			transition(EnemyAggroState.state_name)

	else:
		if current_state_name != EnemyIdleState.state_name:
			transition(EnemyIdleState.state_name)


func set_stun(duration: float):
	states[EnemyStunState.state_name].set_duration(duration)
	transition(EnemyStunState.state_name)
