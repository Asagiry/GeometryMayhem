class_name EffectFactory

extends Node

static func create_burn(params := {}) -> Effect:
	var e := Effect.new()
	e.name = params.get("name", "Burn")
	e.effect_type = Util.EffectType.BURN
	e.behavior = Util.EffectBehavior.DOT
	e.damage = DamageData.new()
	e.damage.amount = params.get("damage", 10.0)
	e.damage.damage_categoty = Util.DamageCategory.MAGICAL
	e.duration = params.get("duration", 5.0)
	e.tick_interval = params.get("tick_interval", 1.0)
	return e


static func create_slow(params := {}) -> Effect:
	var e := Effect.new()
	e.name = params.get("name", "Slow")
	e.effect_type = Util.EffectType.SLOW
	e.behavior = Util.EffectBehavior.DEBUFF
	e.stat_modifiers = StatModifierData.new()
	e.stat_modifiers.speed_multiplier = params.get("speed_multiplier", 0.5)
	e.duration = params.get("duration", 3.0)
	return e
