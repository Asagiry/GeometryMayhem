class_name DashAttack

extends Node2D

var player: CharacterBody2D

@onready var hit_box_component = %HitBoxComponent
@onready var dash_hit_box_shape: CollisionShape2D = %DashHitBoxShape


func _ready():
	if get_tree().get_first_node_in_group("player") != null:
		player = get_tree().get_first_node_in_group("player")

func _on_hit_box_component_area_entered(area: Area2D) -> void:
	if area is not HurtBox:
		return
	if area.has_method("deal_damage"):
		area.deal_damage(hit_box_component.damage_data)
	if area.has_method("apply_effect"):
		area.apply_effect(player.effects)
