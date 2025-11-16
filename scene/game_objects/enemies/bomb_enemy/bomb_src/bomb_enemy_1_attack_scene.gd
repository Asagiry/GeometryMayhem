class_name BombEnemyAttackScene1

extends Node2D

const EXPLOSION_VARIABLE_FOR_SCALE: float = 25.0

var effects

@onready var explosion: GPUParticles2D = $Explosion
@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_2d: CollisionShape2D = $HitBoxComponent/CollisionShape2D


func set_enemy(p_enemy: EnemyController):
	effects = p_enemy.effects.duplicate()


func set_explosion_range(explosion_range):
	collision_shape_2d.shape.radius = explosion_range
	explosion.process_material.scale_min = explosion_range / EXPLOSION_VARIABLE_FOR_SCALE
	explosion.process_material.scale_max = explosion_range / EXPLOSION_VARIABLE_FOR_SCALE


func _on_hit_box_component_area_entered(area: Area2D) -> void:
	if area is not HurtBox:
		return
	if area.has_method("deal_damage"):
		area.deal_damage(hit_box_component.damage_data)
	if area.has_method("apply_effect"):
		area.apply_effect(effects, hit_box_component.damage_data)
