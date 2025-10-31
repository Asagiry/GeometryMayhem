class_name RangeEnemyAttackScene1

extends Node2D


var projectile_speed: float = 200.0
var direction: Vector2 = Vector2.ZERO
var enemy

@onready var hit_box_component = %HitBoxComponent


func _physics_process(delta: float) -> void:
	position += projectile_speed * direction * delta


func _on_hit_box_component_area_entered(area: Area2D) -> void:
	if area is not HurtBox:
		return
	if area.has_method("deal_damage"):
		area.deal_damage(hit_box_component.damage_data)
	if area.has_method("apply_effect"):
		area.apply_effect(enemy.effects)


func set_enemy(p_enemy):
	enemy = p_enemy


func set_projectile_speed(p_projectile_speed):
	projectile_speed = p_projectile_speed


func set_direction(p_direction):
	direction = p_direction
