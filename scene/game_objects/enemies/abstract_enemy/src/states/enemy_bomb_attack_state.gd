class_name EnemyBombAttackState

extends EnemyState

signal attack_started

const EXPLOSION_DELAY: float = 1.0

static var state_name = "EnemyAttackState"

var on_cooldown: bool = false

func _init(enemy_controller: EnemyController) -> void:
	super(enemy_controller)
	attack_controller.attack_started.connect(_on_attack_started)


func enter() -> void:

	await enemy.get_tree().create_timer(EXPLOSION_DELAY).timeout
	
	var aggro_state = state_machine.states["EnemyAggroState"] as EnemyAggroState
	if enemy.is_stunned:
		state_machine.transition(EnemyStunState.state_name)
		return
	elif !aggro_state.player_in_attack_zone:
		state_machine.transition(aggro_state.state_name)
		return

	attack_controller.activate_attack()
	
	attack_started.emit()


func _on_attack_started():
	animated_sprite_2d.play("attack")
	pass


func get_state_name() -> String:
	return state_name
