class_name EnemyAggroState
extends EnemyState

static var state_name = "EnemyAggroState"

func enter() -> void:
	animated_sprite_2d.play("aggro")


func process(_delta: float) -> void:
	enemy.movement_component.chase_player()


func _on_player_entered_attack(body:CharacterBody2D):
	if body is PlayerController:
		state_machine.transition(EnemyAttackState.state_name)


func _on_player_exited_aggro(body:CharacterBody2D):
	if body is PlayerController:
		state_machine.transition(EnemyBackState.state_name)


func get_state_name() -> String:
	return state_name
