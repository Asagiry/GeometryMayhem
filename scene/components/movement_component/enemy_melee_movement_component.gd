class_name EnemyMeleeMovementComponent

extends MovementComponent


func move_to_player(mob: CharacterBody2D):
	var direction = get_direction()
	mob.velocity = accelerate_to_direction(direction)
	mob.move_and_slide()


func get_direction():
	var mob = owner as Node2D
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		return (player.global_position - mob.global_position).normalized()
	return Vector2.ZERO
