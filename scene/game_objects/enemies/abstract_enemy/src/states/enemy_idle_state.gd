class_name EnemyIdleState
extends EnemyState

static var state_name = "EnemyIdleState"
func _init(enemy_controller: EnemyController) -> void:
	super(enemy_controller)
	enemy.aggro_zone.body_entered.connect(_on_player_entered_aggro)

func enter() -> void:
	animated_sprite_2d.play("idle")
	enemy.movement_component.start_patrol()


func physics_process(_delta: float) -> void:
	enemy.movement_component.handle_movement()


func _on_player_entered_aggro(body:CharacterBody2D):
	if (state_machine.current_state.get_state_name() == get_state_name()):
		if body is PlayerController:
			state_machine.transition(EnemyAggroState.state_name)


func _on_stun_applied(duration: float):
	super(duration)
	state_machine.transition(EnemyStunState.state_name)


func get_state_name() -> String:
	return state_name
