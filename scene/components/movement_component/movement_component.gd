class_name MovementComponent

extends Node

@export var max_speed: float = 0
@export var acceleration: float = 0

var current_speed: float
var current_velocity = Vector2.ZERO


func _ready() -> void:
	current_speed = max_speed


func accelerate_to_direction(direction: Vector2):
	var final_velocity = max_speed * direction
	current_velocity = current_velocity.lerp(final_velocity, 1 - \
	exp(-acceleration * get_process_delta_time()))
	return current_velocity
