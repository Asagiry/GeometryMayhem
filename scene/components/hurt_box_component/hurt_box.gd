class_name HurtBox

extends Area2D

#TODO test ui signal!!!(в обычной логике - этот сигнал не нужен. убрать его,
#когда test_ui не будет нужен)
signal effect_is_applied(
	effect_type: Util.EffectType,
	effect_duration: float,
	effect_behavior: Util.EffectBehavior,
	)

const LUCK_POTENCY: float = 0.01

@export var health_component: HealthComponent

@onready var hurt_box_shape = %HurtBoxShape

func deal_damage(damage_data: DamageData):
	health_component.take_damage(damage_data)


func apply_effect(
	effects: Array[Effect],
	magic_find: float,
	damage_data_from_attack: DamageData = null
) -> void:
	if not owner or not effects:
		return

	for effect in effects:
		if effect.chance_to_apply >= 1.0:
			_apply_effect(effect, damage_data_from_attack)
			continue
		if effect.chance_to_apply <= 0.0:
			continue

		if _roll_success(
			_calculate_final_chance(
				effect.chance_to_apply,
				magic_find
			)
		):
			_apply_effect(effect, damage_data_from_attack)


func _apply_effect(effect: Effect, damage_data_from_attack: DamageData):
	if damage_data_from_attack and effect.effect_type == Util.EffectType.BLEED:
		effect.set_damage_data(damage_data_from_attack)

	owner.effect_receiver.apply_effect(effect)
	#TODO сигнал от test_ui - убрать, когда test_ui не будет нужен.
	effect_is_applied.emit(effect.effect_type, effect.duration, effect.behavior)


## Проверяет шанс.
func _roll_success(chance: float) -> bool:
	return randf() <= chance


## 1 единица удачи дает +1% к исходному шансу (relative boost).
## При 100 удачи шанс удваивается.
func _calculate_final_chance(base_chance: float, magic_find: float) -> float:
	var luck_multiplier_bonus = magic_find * LUCK_POTENCY
	luck_multiplier_bonus = min(luck_multiplier_bonus, 1.0)
	var final_chance = base_chance * (1.0 + luck_multiplier_bonus)
	return clamp(final_chance, 0.0, 0.95)
