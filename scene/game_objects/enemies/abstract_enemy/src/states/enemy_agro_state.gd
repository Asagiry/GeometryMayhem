class_name EnemyAgroState
extends EnemyState

static var state_name = "EnemyAgroState"

func enter() -> void:
	animated_sprite_2d.play("aggro")


func process(_delta: float) -> void:
	enemy.movement_component.move_to_player(enemy)
	if _player_in_hit_box():
		enemy_state_machine.transition(EnemyAttackState.state_name)
	if not _player_in_agro_zone():
		enemy_state_machine.transition(EnemyBackState.state_name)


func _player_in_agro_zone() -> bool:
	if enemy.agro_zone:
		var overlapping_bodies = enemy.agro_zone.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("player"):
				return true
	return false


func _player_in_hit_box() -> bool:
	if enemy.hit_box:
		var overlapping_bodies = enemy.hit_box.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("player"):
				return true
	return false


func get_state_name() -> String:
	return state_name
