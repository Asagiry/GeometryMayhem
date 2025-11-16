class_name EffectBuilder

extends Node

var _effect: Effect

func _init():
	_effect = Effect.new()


## Добавление базовых свойств эффекта.
## Если behavior = INSTANT, то duration не указывается
func set_basic(
	type: Util.EffectType,
	behavior: Util.EffectBehavior,
	positivity: Util.EffectPositivity,
	duration: float = 0.0
	) -> EffectBuilder:
	_effect.effect_type = type
	_effect.behavior = behavior
	_effect.positivity = positivity
	_effect.duration = duration
	return self


## Добавление урона к эффекту.
func with_damage(
	amount: float,
	category: Util.DamageCategory = Util.DamageCategory.DEFAULT
	) -> EffectBuilder:
	_effect.damage = DamageData.new(amount, category)
	return self


## Добавление модификаторов статов к эффекту.
func with_stat_modifiers(modifiers: StatModifierData) -> EffectBuilder:
	_effect.stat_modifiers = modifiers
	return self


func with_tick_interval(tick_interval: float) -> EffectBuilder:
	_effect.tick_interval = tick_interval
	return self


## Добавление процента к эффекту, если эффект оперирует процентами.
## Пример: Эффект BLEED наносит урон от % атаки того, кто наложил этот эффект.
func with_percent(percent_value: float) -> EffectBuilder:
	_effect.percent = percent_value
	return self


## Добавление скрипта к эффекту, если нужно указать скрипт вручную.
func with_special_behavior(script: Script) -> EffectBuilder:
	_effect.behavior_script = script
	return self

## Добавление шанса наложения эффекта.
## Где 0.0 = 0%, 1.0 = 100%.
func with_chance(chance: float) -> EffectBuilder:
	_effect.chance_to_apply = chance
	return self


func build() -> Effect:
	return _effect
