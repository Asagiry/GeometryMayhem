class_name PlayerMovementComponent

extends MovementComponent

signal movement_started(pos: Vector2)

const DISTANCE_TO_CENTER: float = 50.0

var is_enable : bool = false
var is_pulled_to_center: bool = false
var pull_strength_base: float = 100.0      # начальная сила
var pull_strength_max: float = 2000.0      # максимальная сила
var pull_strength: float= pull_strength_base
var pull_grow_speed: float = 250.0         # скорость роста силы в секунду
var external_force: Vector2 = Vector2.ZERO

func _ready():
	super()
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	owner.animated_sprite_2d.position = owner.animated_sprite_2d.position.round()
	var direction = get_movement_vector().normalized()
	if direction != Vector2.ZERO:
		last_direction = direction
		movement_started.emit(global_position)

		var target_angle = last_direction.angle() + PI / 2
		rotation = lerp_angle(rotation, target_angle, get_rotation_speed() * delta)

	velocity = accelerate_to_direction(direction)
	if is_pulled_to_center:
		velocity += _get_center_pull_velocity(delta)

	move_and_slide()


func enable_movement(enable: bool):
	is_enable = enable
	set_physics_process(enable)


func get_movement_vector() -> Vector2:
	var vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return vector

func start_pull_to_center(
	base_strength: float = 100.0,
	strength_grow: float = 250.0
	):
	pull_strength_base = base_strength
	pull_grow_speed = strength_grow
	is_pulled_to_center = true


func stop_pull_to_center():
	is_pulled_to_center = false


func _connect_signals():
	super()
	Global.game_timer_timeout.connect(_on_game_timer_timeout)


func _get_center_pull_velocity(delta: float) -> Vector2:
	if not owner_node:
		return Vector2.ZERO

	var target = Vector2.ZERO
	var dir = target - global_position
	var distance = dir.length()

	if distance < DISTANCE_TO_CENTER:
		is_pulled_to_center = false
		pull_strength = pull_strength_base
		Global.player_pulled.emit()
		return Vector2.ZERO

	pull_strength = pull_strength + pull_grow_speed * delta
	var pull_force = pull_strength #/ (distance / 32 + 1.0)
	return dir.normalized() * pull_force


func _on_game_timer_timeout():
	start_pull_to_center(0.001, 5.0)
