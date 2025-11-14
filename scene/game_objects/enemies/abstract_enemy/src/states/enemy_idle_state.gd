class_name EnemyIdleState
extends EnemyState

static var state_name = "EnemyIdleState"

func enter() -> void:
	animated_sprite_2d.play("idle")
	enemy.movement_component.start_patrol()


func physics_process(_delta: float) -> void:
	if enemy.get_back:
		enemy.movement_component.get_back()
	else:
		enemy.movement_component.handle_movement()


func get_state_name() -> String:
	return state_name
