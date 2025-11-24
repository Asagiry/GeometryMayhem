class_name BossMovementComponent

extends MovementComponent


var player: PlayerController


func _ready():
	super()
	player = get_tree().get_first_node_in_group("player") as PlayerController


func chase_player(delta: float = 0):
	var direction = _get_direction_to_player()
	if direction != Vector2.ZERO:
		last_direction = direction
	velocity = accelerate_to_direction(direction)
	var target_angle = (player.global_position - global_position).angle() - PI/2
	rotation = lerp_angle(rotation, target_angle, get_rotation_speed() * delta)
	move_and_slide()


func _get_direction_to_player() -> Vector2:
	var mob = owner as Node2D
	if player != null:
		return (player.global_position - mob.global_position).normalized()
	return Vector2.ZERO
