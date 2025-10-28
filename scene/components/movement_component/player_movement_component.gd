class_name PlayerMovementComponent

extends MovementComponent

signal movement_started(pos: Vector2)

@export var rotation_speed: float = 9.0 #9.0(AI)

var last_direction: Vector2 = Vector2.UP
var player

@onready var effect_receiver: EffectReceiver = %EffectReceiver

func _ready():
	current_speed = max_speed
	player = get_tree().get_first_node_in_group("player")
	effect_receiver.stats_changed.connect(_on_stats_changed)


func handle_movement(delta: float):
	var direction = get_movement_vector().normalized()
	speed_multiplier = effect_receiver.speed_multiplier
	if direction != Vector2.ZERO:
		last_direction = direction
	player.velocity = accelerate_to_direction(direction)

	if direction!=Vector2.ZERO:
		var target_angle = last_direction.angle() + PI / 2
		player.rotation = lerp_angle(player.rotation, target_angle, rotation_speed * delta)

	if direction!=Vector2.ZERO:
		movement_started.emit(player.global_position)

	player.move_and_slide()


func get_movement_vector() -> Vector2:
	var vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return vector

func _on_stats_changed(updated_stats: Dictionary):
	if updated_stats.has("speed_multiplier"):
		speed_multiplier = updated_stats["speed_multiplier"]
