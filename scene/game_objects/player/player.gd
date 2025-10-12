extends CharacterBody2D

@export var rotation_speed: float = 9.0
@export var grace_period_time: float = 0.5

var last_direction: Vector2 = Vector2.ZERO
var enemies_colliding = 0
var enemy_damage = 0
var base_speed = 0
var is_parrying: bool = false

@onready var animated_sprite_2d = %AnimatedSprite2D
@onready var grace_period = %GracePeriod
@onready var movement_component = %MovementComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var parry_component: ParryComponent = %ParryComponent

func _ready():
	base_speed = movement_component.max_speed
	health_component.died.connect(_on_died)
	health_component.health_decreased.connect(_on_health_decreased)


func _process(delta):
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()
	if direction != Vector2.ZERO:
		last_direction = direction
	velocity = movement_component.accelerate_to_direction(direction)
	move_and_slide()

	if not is_parrying:
		if direction != Vector2.ZERO:
			animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("idle")

	var target_angle = last_direction.angle() + PI / 2
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)

	check_if_damaged()

	if Input.is_action_just_pressed("parry"):
		is_parrying = true
		parry_component.activate_parry()
		animated_sprite_2d.play("block")
		await animated_sprite_2d.animation_finished
		is_parrying = false


func get_movement_vector() -> Vector2:
	var movement_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var movement_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(movement_x, movement_y)


func check_if_damaged():
	if enemies_colliding == 0 || !grace_period.is_stopped():
		return
	health_component.take_damage(enemy_damage)
	grace_period.start(grace_period_time)


func _on_player_hurt_box_area_entered(area: Area2D) -> void:
	if not area.has_method("enemy_damage"):
		return
	enemy_damage = area.enemy_damage()
	enemies_colliding += 1
	check_if_damaged()


func _on_player_hurt_box_area_exited(_area: Area2D) -> void:
	enemies_colliding -= 1


func _on_died():
	queue_free()


func _on_health_decreased():
	pass
