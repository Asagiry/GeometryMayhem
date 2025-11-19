class_name MovementComponent

extends BaseComponent

var current_speed: float = 0.0
var direction_modifier: float = 1.0

var speed_multiplier: float = 1.0
var freeze_multiplier: float = 1.0

var current_velocity = Vector2.ZERO
var last_direction: Vector2 = Vector2.UP


var effect_receiver: EffectReceiver

var velocity: Vector2:
	get: return owner_node.velocity if owner_node else Vector2.ZERO
	set(value):
		if owner_node:
			owner_node.velocity = value


var rotation: float:
	get: return owner_node.rotation if owner_node else 0.0
	set(value):
		if owner_node:
			owner_node.rotation = value


var global_position: Vector2:
	get: return owner_node.global_position if owner_node else Vector2.ZERO
	set(value):
		if owner_node:
			owner_node.global_position = value


func _ready() -> void:
	super._ready()
	_enter_variables()
	_connect_signals()


func accelerate_to_direction(direction: Vector2) -> Vector2:
	if not owner_node:
		return Vector2.ZERO

	direction *= direction_modifier
	var final_max_speed = get_max_speed()
	var final_velocity = final_max_speed * direction
	var current_acceleration = get_acceleration()

	current_velocity = current_velocity.lerp(
		final_velocity,
		1 - exp(-current_acceleration * get_physics_process_delta_time())
	)

	return current_velocity


func move_and_slide() -> void:
	if owner_node:
		owner_node.move_and_slide()


func stop() -> void:
	current_velocity = Vector2.ZERO
	if owner_node:
		owner_node.velocity = Vector2.ZERO


func is_moving() -> bool:
	return current_velocity.length_squared() > 1.0



func set_freeze_multiplier(multiplier: float) -> void:
	freeze_multiplier = multiplier


func set_speed_multiplier(multiplier: float) -> void:
	speed_multiplier = multiplier


func set_direction_modifier(modifier: float) -> void:
	direction_modifier = modifier


func get_max_speed() -> float:
	return get_stat("max_speed") * speed_multiplier * freeze_multiplier


func get_acceleration() -> float:
	return get_stat("acceleration")


func get_rotation_speed() -> float:
	return get_stat("rotation_speed")


func get_last_direction() -> Vector2:
	return last_direction


func _enter_variables():
	effect_receiver = owner.get_effect_receiver()


func _connect_signals():
	effect_receiver.movement_component_effects_changed.connect(_on_effect_stats_changed)


func _on_effect_stats_changed(updated_stats: Dictionary):
	if updated_stats.has("freeze_multiplier"):
		freeze_multiplier = updated_stats["freeze_multiplier"]

	if updated_stats.has("speed_multiplier"):
		speed_multiplier = updated_stats["speed_multiplier"]

	if updated_stats.has("direction_modifier"):
		direction_modifier = updated_stats["direction_modifier"]
