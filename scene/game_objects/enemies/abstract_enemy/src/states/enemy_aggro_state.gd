class_name EnemyAggroState
extends EnemyState

static var state_name = "EnemyAggroState"


func enter() -> void:
	animated_sprite_2d.play("aggro")


func physics_process(_delta: float) -> void:
	enemy.movement_component.chase_player()


func get_state_name() -> String:
	return state_name
