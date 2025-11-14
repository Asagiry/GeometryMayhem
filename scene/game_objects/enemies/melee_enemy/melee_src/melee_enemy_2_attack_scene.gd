class_name MeleeEnemyAttackScene2
extends Node2D

var enemy
var attacked: bool = false


@onready var hit_box_component = %HitBoxComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var fire_particles: CPUParticles2D = %FireParticles
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D

func _ready() -> void:
	randomize()
	fire_particles.emitting = false  
	fire_particles.local_coords = true

func _on_hit_box_component_area_entered(area: Area2D) -> void:
	if area is not HurtBox:
		return
	if area.has_method("deal_damage") and attacked == false:
		area.deal_damage(hit_box_component.damage_data)
		attacked= true
	if area.has_method("apply_effect"):
		area.apply_effect(enemy.effects)

func start_swing():
	fire_particles.emitting = true

func _on_animation_finished(anim_name: String):
	if anim_name == "attack":
		fire_particles.emitting = false
		attacked = true
		queue_free()  

func set_enemy(p_enemy):
	enemy = p_enemy

func set_attack_range(attack_range):
	fire_particles.lifetime = attack_range / fire_particles.initial_velocity_min
	print(fire_particles.orbit_velocity_min)
	print(fire_particles.lifetime )
	collision_shape_2d.position = Vector2(attack_range, 0.0)

func set_speed_scale(p_speed_scale):
	fire_particles.speed_scale = p_speed_scale
