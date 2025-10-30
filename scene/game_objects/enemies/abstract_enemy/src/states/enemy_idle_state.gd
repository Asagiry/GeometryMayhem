class_name EnemyIdleState
extends EnemyState

static var state_name = "EnemyIdleState"


func enter() -> void:
	animated_sprite_2d.play("idle")
	enemy.movement_component.start_patrol()


func process(_delta: float) -> void:
	enemy.movement_component.handle_movement()

func _on_player_entered_aggro(body:CharacterBody2D):
	if (state_machine.current_state.get_state_name() == get_state_name()):
		if body is PlayerController:
			state_machine.transition(EnemyAggroState.state_name)

func get_state_name() -> String:
	return state_name
