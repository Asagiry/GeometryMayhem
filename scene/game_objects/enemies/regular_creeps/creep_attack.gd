class_name CreepAttack

extends Node2D

var enemy

@onready var enemy_hit_box_component: EnemyHitBoxComponent = %EnemyHitBoxComponent


func set_enemy(enemy_node: Node2D):
	enemy = enemy_node
	print("Enemy set: ", enemy)


func _on_enemy_hit_box_component_area_entered(area: Area2D) -> void:
	if not area.is_in_group("player_hurt_box"):
		return
	if area.has_method("deal_damage"):
		area.deal_damage(enemy_hit_box_component.damage_data)
	if area.has_method("apply_effect"):
		print("sginal enemy = ", enemy)
		print("enemy_effects = ", enemy.effects == null)
		area.apply_effect(enemy.effects)
