class_name EnemyAttackState
extends EnemyState

static var state_name = "EnemyAttackState"

func enter() -> void:
	animated_sprite_2d.play("attack")


func _on_player_exited_attack(body:CharacterBody2D):
	if body is PlayerController:
		state_machine.transition(EnemyAggroState.state_name)

func get_state_name() -> String:
	return state_name
