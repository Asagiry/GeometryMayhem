class_name EffectFactory

extends Node

static func create_effect(params := {}) -> Array[Effect]:
	var effect_arr: Array[Effect] = []
	var e := Effect.new()
	for i in params.keys():
		var effect_data = params[i]
		match effect_data["effect_name"]:
			"BURN", "POISON", "BLEED":
				effect_arr.append(_create_dot_effect(e, effect_data))
			"SLOW", "CURSE", "ARMOR_DEBUFF", "DAMAGE_REDUCTION":
				effect_arr.append(_create_debuff_effect(e, effect_data))
	return effect_arr


static func _create_dot_effect(e: Effect, effect_data: Dictionary):
	e.name = "DotEffect" + effect_data["effect_name"]
	e.effect_type = Util.EffectType.get(effect_data["effect_name"])
	e.behavior = Util.EffectBehavior.DOT
	e.damage = DamageData.new()
	e.damage.amount = effect_data.get("damage", 1.0)
	e.damage.damage_categoty = Util.DamageCategory.DEFAULT
	e.duration = effect_data.get("duration", 2.0)
	e.tick_interval = effect_data.get("tick_interval", 1.0)
	return e


static func _create_debuff_effect(e: Effect, effect_data: Dictionary):
	e.name = "DotEffect" + effect_data["effect_name"]
	e.effect_type = Util.EffectType.get(effect_data["effect_name"])
	e.behavior = Util.EffectBehavior.DEBUFF
	e.stat_modifiers = StatModifierData.new()
	e.stat_modifiers.speed_multiplier = effect_data.get("speed_multiplier", 1.0)
	e.stat_modifiers.attack_multiplier = effect_data \
	.get("attack_multiplier", 1.0)
	#e.stat_modifiers.magical_attack_multiplier = effect_data \
	#.get("magical_attack_multiplier", 1.0)
	e.stat_modifiers.armor_multiplier = effect_data \
	.get("armor_multiplier", 1.0)
	#e.stat_modifiers.magical_resistance_multiplier = effect_data \
	#.get("magical_resistance_multiplier", 1.0)
	e.stat_modifiers.forward_receiving_damage_multiplier = effect_data \
	.get("forward_receiving_damage_multiplier", 1.0)
	e.duration = effect_data.get("duration", 1.0)
	return e

static func _create_special_effect(e: Effect, effect_data: Dictionary) -> Effect:
	e.name = "SpecialEffect_" + effect_data["effect_name"]
	e.effect_type = Util.EffectType.get(effect_data["effect_name"])
	e.behavior = Util.EffectBehavior.SPECIAL
	e.duration = effect_data.get("duration", 2.0)
	e.behavior_class = effect_data.get("behavior_class", "") # "FreezeEffect"
	return e
