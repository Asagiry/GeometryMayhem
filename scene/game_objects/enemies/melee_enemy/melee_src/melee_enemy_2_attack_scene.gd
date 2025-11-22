class_name MeleeEnemyAttackScene2
extends Node2D

const PARTICLES_MULTIPLIER:int = 40

var enemy
var attacked: bool = false

var _attack_range: float = 0.0
var _attack_angle: float = 90.0
var _attack_duration: float = 0.3

@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var fire_particles: CPUParticles2D = %FireParticles
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D


func _ready() -> void:
	randomize()
	fire_particles.emitting = false
	fire_particles.local_coords = true
	collision_shape_2d.position = Vector2.ZERO
	collision_shape_2d.disabled = true
	_update_collision_sector(0.0)


func _on_hit_box_component_area_entered(area: Area2D) -> void:
	if area is not HurtBox:
		return
	if area.has_method("deal_damage") and attacked == false:
		area.deal_damage(hit_box_component.damage_data)
		attacked = true
	if area.has_method("apply_effect"):
		area.apply_effect(enemy.effects)


func start_swing():
	fire_particles.emitting = true
	collision_shape_2d.disabled = false
	var attack_anim := animation_player.get_animation("attack")
	var anim_len := attack_anim.length / animation_player.speed_scale
	_attack_duration = anim_len * 1.8
	_start_fire_tween()


func _on_animation_finished(anim_name: String):
	print(fire_particles.amount)
	if anim_name == "attack":
		fire_particles.emitting = false
		attacked = true
		queue_free()


func set_enemy(p_enemy):
	enemy = p_enemy


func set_attack_range(attack_range: float, angle_deg: float) -> void:
	_attack_range = attack_range
	_attack_angle = angle_deg
	fire_particles.amount = int(_attack_range) * PARTICLES_MULTIPLIER
	var vel = fire_particles.initial_velocity_min
	if vel <= 0.0:
		vel = 1.0
	fire_particles.lifetime = attack_range / vel
	print(_attack_range)
	_update_collision_sector(0.0)


func set_speed_scale(p_speed_scale: float) -> void:
	fire_particles.speed_scale = p_speed_scale
	if p_speed_scale != 0.0:
		_attack_duration = 1.2

func _update_collision_sector(progress: float) -> void:
	var radius = _attack_range * clamp(progress, 0.0, 1.0)
	var shape = ConvexPolygonShape2D.new()
	var half_angle_rad = deg_to_rad(_attack_angle / 2.0)
	var segments = max(8, int(_attack_angle / 22.5))
	var points: PackedVector2Array = [Vector2.ZERO]
	for i in range(segments + 1):
		var angle_rad = -half_angle_rad + (i / float(segments)) * (half_angle_rad * 2.0)
		points.append(Vector2(cos(angle_rad) * radius, sin(angle_rad) * radius))
	shape.points = points
	collision_shape_2d.shape = shape


func _start_fire_tween() -> void:
	if _attack_range <= 0.0 or _attack_duration <= 0.0:
		_update_collision_sector(1.0)
		return
	var tween = create_tween()
	var start_progress = 0.0
	var end_progress = 1.0
	tween.tween_method(
		func(progress_value: float) -> void:
			_update_collision_sector(progress_value),
		start_progress,
		end_progress,
		_attack_duration
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(
		func() -> void:
			_update_collision_sector(0.0)
			collision_shape_2d.disabled = true
	)
	
