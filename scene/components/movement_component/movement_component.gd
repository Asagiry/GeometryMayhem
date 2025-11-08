class_name MovementComponent
extends OwnerAwareComponent  # Меняем наследование

var entity: CharacterBody2D
var current_speed: float = 0.0
var direction_modifier: float = 1.0

var speed_multiplier: float = 1.0
var freeze_multiplier: float = 1.0

var current_velocity = Vector2.ZERO
var last_direction: Vector2 = Vector2.UP

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


var global_position: Vector2:
	get: return entity.global_position if entity else Vector2.ZERO
	set(value):
		if entity:
			entity.global_position = value

func _ready() -> void:
	super._ready()  # Вызовет _setup_owner_reference() и _setup_stat_subscriptions()


func _setup_owner_reference():
	super._setup_owner_reference()

	# Получаем entity из owner (должен быть CharacterBody2D)
	if owner_node is CharacterBody2D:
		entity = owner_node
	else:
		push_error("MovementComponent owner must be CharacterBody2D")


func get_max_speed() -> float:
	return get_stat("max_speed") * speed_multiplier * freeze_multiplier


func get_acceleration() -> float:
	return get_stat("acceleration")


func get_rotation_speed() -> float:
	return get_stat("rotation_speed")


func accelerate_to_direction(direction: Vector2) -> Vector2:
	if not entity:
		return Vector2.ZERO

	direction *= direction_modifier
	var final_max_speed = get_max_speed()
	var final_velocity = final_max_speed * direction
	var current_acceleration = get_acceleration()

	current_velocity = current_velocity.lerp(
		final_velocity,
		1 - exp(-current_acceleration * get_process_delta_time())
	)

	# Сохраняем последнее направление (если двигаемся)
	if direction.length_squared() > 0.1:
		last_direction = direction.normalized()

	return current_velocity


func rotate_towards_direction(direction: Vector2) -> void:
	if not entity or direction.length_squared() < 0.1:
		return

	var target_rotation = direction.angle() + PI/2  # +PI/2 если спрайт смотрит вверх
	var rotation_diff = wrapf(target_rotation - entity.rotation, -PI, PI)
	var rotation_step = get_rotation_speed() * get_process_delta_time()

	if abs(rotation_diff) <= rotation_step:
		entity.rotation = target_rotation
	else:
		entity.rotation += rotation_step * sign(rotation_diff)


func move_and_slide() -> void:
	if entity:
		entity.move_and_slide()


func set_freeze_multiplier(multiplier: float) -> void:
	freeze_multiplier = multiplier


func set_speed_multiplier(multiplier: float) -> void:
	speed_multiplier = multiplier


func set_direction_modifier(modifier: float) -> void:
	direction_modifier = modifier


# Дополнительные полезные методы
func stop() -> void:
	current_velocity = Vector2.ZERO
	if entity:
		entity.velocity = Vector2.ZERO


func get_last_direction() -> Vector2:
	return last_direction


func is_moving() -> bool:
	return current_velocity.length_squared() > 1.0
