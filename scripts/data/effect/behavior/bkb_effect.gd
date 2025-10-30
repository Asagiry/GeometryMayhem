extends SpecialEffectBehavior


func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	receiver.clear_effects(Util.EffectPositivity.NEGATIVE)


func end() -> void:
	_receiver.active_special_states.erase(_effect.effect_type)
	super.end()
