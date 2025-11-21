class_name BossHurtBox

extends Area2D

@export var health_component: BossHealthComponent

func deal_damage(damage_data: DamageData):
	health_component.take_damage(damage_data,name)
