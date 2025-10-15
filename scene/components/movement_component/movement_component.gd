extends Node

@export var max_speed: int = 50
@export var acceleration: float = 5.0

var current_velocity = Vector2.ZERO


func accelerate_to_direction(direction: Vector2):
	var final_velocity = max_speed * direction
	current_velocity = current_velocity.lerp(final_velocity, 1 - \
	exp(-acceleration * get_process_delta_time()))
	return current_velocity
