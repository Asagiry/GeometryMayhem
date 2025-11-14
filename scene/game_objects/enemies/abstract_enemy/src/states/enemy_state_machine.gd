class_name EnemyStateMachine

extends StateMachine

var player: PlayerController
var enemy: EnemyController

enum PlayerVisibility {
	AGGRO,
	ATTACK
}

var player_zones: Dictionary = {
	PlayerVisibility.ATTACK: false,
	PlayerVisibility.AGGRO: false
}

func start_machine(init_states: Array[State]) -> void:
	super(init_states)

	player = get_tree().get_first_node_in_group("player") as PlayerController
	enemy = owner as EnemyController

	enemy.effect_receiver.stun_applied.connect(_on_stun_applied)

	enemy.attack_zone.monitorable = false
	enemy.aggro_zone.monitorable = false

	enemy.attack_zone.body_entered.connect(func(body):
		player_zones[PlayerVisibility.ATTACK] = true
		call_deferred("_on_update_enemy_state")
	)
	enemy.attack_zone.body_exited.connect(func(body):
		player_zones[PlayerVisibility.ATTACK] = false
		call_deferred("_on_update_enemy_state")
	)

	enemy.aggro_zone.body_entered.connect(func(body):
		player_zones[PlayerVisibility.AGGRO] = true
		call_deferred("_on_update_enemy_state")
	)
	enemy.aggro_zone.body_exited.connect(func(body):
		player_zones[PlayerVisibility.AGGRO] = false
		call_deferred("_on_update_enemy_state")
	)
	#Global.update_enemy_state.connect(_on_update_enemy_state)


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


func _on_stun_applied(duration: float):
	enemy.is_stunned = true
	states[EnemyStunState.state_name].set_duration(duration)
	transition(EnemyStunState.state_name)


func get_player_zones() -> Dictionary:
	var player_size = player.collision.shape.radius
	var player_pos = player.global_position
	var enemy_pos = enemy.global_position
	var aggro_range_sq = pow(enemy.stats.aggro_range+player_size,2)
	var attack_range_sq = pow(enemy.stats.attack_range_zone+player_size,2)
	var dist_sq = player_pos.distance_squared_to(enemy_pos)

	return {
		PlayerVisibility.AGGRO: dist_sq < aggro_range_sq,
		PlayerVisibility.ATTACK: dist_sq < attack_range_sq
	}
