class_name HurtBox

extends Area2D

#TODO test ui signal!!!(в обычной логике - этот сигнал не нужен. убрать его,
#когда test_ui не будет нужен)
signal effect_is_applied(
	effect_type: Util.EffectType,
	effect_duration: float,
	effect_behavior: Util.EffectBehavior,
	)

@export var health_component: HealthComponent

@onready var hurt_box_shape: CollisionShape2D = %HurtBoxShape

func deal_damage(damage_data: DamageData):
	health_component.take_damage(damage_data)


func apply_effect(effects: Array[Effect], damage_data_from_attack: DamageData = null):
	if owner == null:
		return

	if effects == null:
		return

	for effect in effects:
		if damage_data_from_attack:
			if effect.effect_type == Util.EffectType.BLEED:
				effect.set_damage_data(damage_data_from_attack)

		#ДОБАВИТЬ МОДУЛЬ ПОДСЧЕТА УДАЧА И НАЛОЖЕНИЯ ЭФФЕКТА
		# <--------------------------->
		owner.effect_receiver.apply_effect(effect)

		#TODO emit этого же сигнала - убрать его, когда test_ui не будет нужен.
		effect_is_applied.emit(effect.effect_type, effect.duration, effect.behavior)
