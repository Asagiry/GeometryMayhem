extends Node

@export var max_speed: float = 60
@export var acceleration: float = 5.0

var current_speed: float
var speed_multiplier: float = 1.0
var current_velocity = Vector2.ZERO

func _ready() -> void:
	current_speed = max_speed


func move_to_player(mob: CharacterBody2D):
	var direction = get_direction()
	mob.velocity = accelerate_to_direction(direction)
	mob.velocity += mob.effect_receiver.velocity_knockback
	mob.move_and_slide()


func get_direction():
	var mob = owner as Node2D
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		return (player.global_position - mob.global_position).normalized()
	return Vector2.ZERO


func accelerate_to_direction(direction: Vector2):
	var final_velocity = max_speed * direction * speed_multiplier
	current_velocity = current_velocity.lerp(final_velocity, 1 - \
	exp(-acceleration * get_process_delta_time()))
	return current_velocity
