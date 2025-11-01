class_name EnemyRangeAttackState

extends EnemyState

static var state_name = "EnemyAttackState"

var on_cooldown: bool = false

var aggro_state

func _init(enemy_controller: EnemyController) -> void:
	super(enemy_controller)
	attack_controller.attack_started.connect(_on_attack_started)
	attack_controller.attack_finished.connect(_on_attack_finished)
	attack_controller.attack_cd_timeout.connect(_on_attack_cd_timeout)


func enter() -> void:
	aggro_state = state_machine.states["EnemyAggroState"] as EnemyAggroState
	perform_attack()


func perform_attack():
	on_cooldown = true
	attack_controller.activate_attack()


func _on_attack_started():
	animated_sprite_2d.play("attack")


func _on_attack_finished():
	if enemy.is_stunned:
		state_machine.transition(EnemyStunState.state_name)
		return

	if !aggro_state.player_in_attack_zone:
		state_machine.transition(EnemyAggroState.state_name)

#TODO тест
func _on_attack_cd_timeout():
	on_cooldown = false
	if aggro_state.player_in_attack_zone:
		perform_attack()
	elif aggro_state.player_in_aggro_zone:
		state_machine.transition(EnemyAggroState.state_name)


func get_state_name() -> String:
	return state_name
