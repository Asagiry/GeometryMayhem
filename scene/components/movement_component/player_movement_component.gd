class_name PlayerMovementComponent

extends MovementComponent

signal movement_started(pos: Vector2)

@onready var effect_receiver: EffectReceiver = %EffectReceiver

func _ready():
	super()
	effect_receiver.stats_changed.connect(_on_stats_changed)


func handle_movement(delta: float):
	var direction = get_movement_vector().normalized()
	if direction != Vector2.ZERO:
		last_direction = direction
	velocity = accelerate_to_direction(direction)

	if direction!=Vector2.ZERO:
		var target_angle = last_direction.angle() + PI / 2
		rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)

	if direction!=Vector2.ZERO:
		movement_started.emit(global_position)

	move_and_slide()


func get_movement_vector() -> Vector2:
	var vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return vector

func _on_stats_changed(updated_stats: Dictionary):
	if updated_stats.has("speed_multiplier"):
		speed_multiplier = updated_stats["speed_multiplier"]
