class_name MovementComponent

extends Node

var entity: CharacterBody2D
var velocity: Vector2:
	get: return entity.velocity if entity else Vector2.ZERO
	set(value):
		if entity:
			entity.velocity = value
var rotation: float:
	get: return entity.rotation if entity else 0.0
	set(value):
		if entity:
			entity.rotation = value

var current_speed: float = 0.0
var rotation_speed: float = 9.0
var max_speed: float
var acceleration: float
var direction_modifier: float = 1.0
var global_position: Vector2:
	get: return entity.global_position if entity else Vector2.ZERO
	set(value):
		if entity:
			entity.global_position = value



var speed_multiplier: float = 1.0
var freeze_multiplier: float = 1.0

var current_velocity = Vector2.ZERO
var last_direction: Vector2 = Vector2.UP


func _ready() -> void:
	max_speed = owner.stats.max_speed
	acceleration = owner.stats.acceleration
	rotation_speed = owner.stats.rotation_speed
	current_speed = max_speed
	entity = owner


func accelerate_to_direction(direction: Vector2):
	direction *= direction_modifier
	var final_velocity = max_speed * direction * speed_multiplier * freeze_multiplier
	current_velocity = current_velocity.lerp(final_velocity, 1 - \
	exp(-acceleration * get_process_delta_time()))
	return current_velocity

func set_freeze_multiplier(multiplier: float):
	freeze_multiplier = multiplier


func move_and_slide():
	entity.move_and_slide()
