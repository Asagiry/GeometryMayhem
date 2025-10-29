class_name EnemyBackState
extends EnemyState

static var state_name = "EnemyBackState"
var return_threshold: float = 5.0

func enter() -> void:
	animated_sprite_2d.play("idle_bug")


func process(_delta: float) -> void:
	enemy.movement_component.move_to_position(enemy, enemy.spawn_position,
	true, enemy.movement_component.return_speed)
	if _player_in_agro_zone():
		enemy_state_machine.transition(EnemyAgroState.state_name)
		return
	if _reached_spawn_point():
		enemy_state_machine.transition(EnemyIdleState.state_name)


func _reached_spawn_point() -> bool:
	return enemy.global_position.distance_to(enemy.spawn_position) <= return_threshold


func _player_in_agro_zone() -> bool:
	if enemy.agro_zone:
		var overlapping_bodies = enemy.agro_zone.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("player"):
				return true
	return false


func get_state_name() -> String:
	return state_name
