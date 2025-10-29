class_name EnemyMovementComponent

extends MovementComponent

var spawn_point: Vector2
var is_patrolling: bool = false
var patrol_timer: Timer

func set_spawn_point(p_spawn_point: Vector2 = Vector2.ZERO):
	spawn_point = p_spawn_point


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
	var direction = (spawn_point - global_position)
	if direction != Vector2.ZERO:
		last_direction = direction
	velocity = accelerate_to_direction(direction)
	move_and_slide()


func _get_direction_to(p_position: Vector2):
	var direction = (p_position-global_position)
	if direction != Vector2.ZERO:
		last_direction = direction
	return direction.normalized()

func start_patrol():
	is_patrolling = true
	var direction = get_random_direction()
	velocity = accelerate_to_direction(direction)

	# Запускаем таймер на случайное время
	_start_random_patrol_timer()
	print("Patrol started")

func stop_patrol():
	is_patrolling = false
	patrol_timer.stop()
	velocity = Vector2.ZERO  # или установи нужное значение
	print("Patrol stopped")

func get_random_direction() -> Vector2:
	var random_angle = randf() * TAU
	return Vector2(cos(random_angle), sin(random_angle))

func _start_random_patrol_timer():
	if is_patrolling:
		var random_time = randf_range(5.0, 10.0)
		patrol_timer.start(random_time)

func _on_patrol_timer_timeout():
	if is_patrolling:
		# Когда таймер заканчивается, снова запускаем патрулирование
		start_patrol()


func stop():
	velocity = Vector2.ZERO
	current_speed = 0.0
