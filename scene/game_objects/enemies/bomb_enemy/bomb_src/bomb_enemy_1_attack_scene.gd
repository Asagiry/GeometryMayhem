class_name BombEnemyAttackScene1

extends Node2D

var enemy

@onready var explosion: GPUParticles2D = $Explosion
@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func set_enemy(p_enemy):
	enemy = p_enemy


func _on_hit_box_component_area_entered(area: Area2D) -> void:
	if area is not HurtBox:
		return
	if area.has_method("deal_damage"):
		area.deal_damage(hit_box_component.damage_data)
	if area.has_method("apply_effect"):
		area.apply_effect(enemy.effects)
	queue_free()
