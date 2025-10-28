class_name MovementComponent

extends Node

const DEFAULT_SPEED_MULTIPLIER: float = 1.0

@export var max_speed: float = 0
@export var acceleration: float = 0

var speed_multiplier: float = 1.0
var current_speed: float
var current_velocity = Vector2.ZERO
var freeze_multiplier: float = 1.0


func _ready() -> void:
	current_speed = max_speed


func accelerate_to_direction(direction: Vector2):
	var final_velocity = max_speed * direction * speed_multiplier * freeze_multiplier
	current_velocity = current_velocity.lerp(final_velocity, 1 - \
	exp(-acceleration * get_process_delta_time()))
	return current_velocity

func set_freeze_multiplier(multiplier: float):
	freeze_multiplier = multiplier
