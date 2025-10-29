class_name EnemyBombMovementComponent
extends MovementComponent

@export var return_speed: float = 70.0
@export var patrol_speed: float = 40.0
@export var patrol_range: float = 50.0

var last_direction: Vector2 = Vector2.UP
var current_patrol_target: Vector2

func _ready():
	current_speed = max_speed


func move_to_player(mob: CharacterBody2D):
	var direction = get_direction()
	if direction != Vector2.ZERO:
		last_direction = direction
	mob.velocity = accelerate_to_direction(direction)
	mob.move_and_slide()


func move_to_position(mob: CharacterBody2D, target_position: Vector2,
 use_custom_speed: bool = false,
 custom_speed: float = 0.0):
	var direction = (target_position - mob.global_position).normalized()
	if direction != Vector2.ZERO:
		last_direction = direction
	if use_custom_speed:
		var original_speed = max_speed
		max_speed = custom_speed
		mob.velocity = accelerate_to_direction(direction)
		max_speed = original_speed
	else:
		mob.velocity = accelerate_to_direction(direction)
	mob.move_and_slide()


func set_new_patrol_target(spawn_position: Vector2):
	var random_angle = randf() * 2 * PI
	var random_distance = randf() * patrol_range
	current_patrol_target = spawn_position + Vector2(cos(random_angle),
	 sin(random_angle)) * random_distance


func get_current_patrol_target() -> Vector2:
	return current_patrol_target

func has_reached_patrol_target(mob: CharacterBody2D, threshold: float = 5.0) -> bool:
	return mob.global_position.distance_to(current_patrol_target) < threshold


func patrol(mob: CharacterBody2D) -> void:
	move_to_position(mob, current_patrol_target, true, patrol_speed)


func get_direction():
	var mob = owner as Node2D
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		return (player.global_position - mob.global_position).normalized()
	return Vector2.ZERO


func stop():
	var mob = get_parent() as CharacterBody2D
	if mob:
		mob.velocity = Vector2.ZERO
		current_speed = 0.0
