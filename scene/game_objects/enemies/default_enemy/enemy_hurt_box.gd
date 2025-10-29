extends Area2D


@export var health_component: HealthComponent

func deal_damage(damage_data: DamageData):
	health_component.take_damage(damage_data)

func apply_effect(effects: Array[Effect]):
	if owner == null:
		return
	for effect in effects:
		owner.effect_receiver.apply_effect(effect)
