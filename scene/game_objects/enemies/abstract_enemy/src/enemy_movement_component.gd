class_name EnemyMovementComponent

extends MovementComponent

var is_patrolling: bool = false
var patrol_timer: Timer
var dir: Vector2
var patrol_speed_multiplier: float = 0.5


func _ready():
	super()
	patrol_timer = Timer.new()
	patrol_timer.one_shot = true
	add_child(patrol_timer)
	patrol_timer.timeout.connect(_on_patrol_timer_timeout)



func chase_player():
	var direction = _get_direction_to_player()
	if direction != Vector2.ZERO:
		last_direction = direction
	velocity = accelerate_to_direction(direction)
	move_and_slide()


func _get_direction_to_player() -> Vector2:
	var mob = owner as Node2D
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		return (player.global_position - mob.global_position).normalized()
	return Vector2.ZERO


func get_back():
	var direction = (owner.stats.spawn_point - global_position).normalized()
	if direction != Vector2.ZERO:
		last_direction = direction
	velocity = accelerate_to_direction(direction)
	move_and_slide()

	if is_reached_spawn_point():
		owner.get_back = false


func is_reached_spawn_point():
	return global_position.distance_to(owner.stats.spawn_point) <= 5.0  # погрешность 5 пикселей


func _get_direction_to(p_position: Vector2):
	var direction = (p_position-global_position)
	if direction != Vector2.ZERO:
		last_direction = direction
	return direction.normalized()


func start_patrol():
	is_patrolling = true
	dir = get_random_direction()
	_start_random_patrol_timer()


func handle_movement():
	velocity = accelerate_to_direction(dir) * patrol_speed_multiplier
	move_and_slide()


func stop_patrol():
	is_patrolling = false
	patrol_timer.stop()
	velocity = Vector2.ZERO
	print("Patrol stopped")


func get_random_direction() -> Vector2:
	var random_angle = randf() * TAU
	return Vector2(cos(random_angle), sin(random_angle))


func _on_zone_ended():
	pass


func _start_random_patrol_timer():
	if is_patrolling:
		var random_time = randf_range(5.0, 10.0)
		patrol_timer.start(random_time)


func _on_patrol_timer_timeout():
	if is_patrolling:
		start_patrol()


func stop():
	velocity = Vector2.ZERO
	current_speed = 0.0
