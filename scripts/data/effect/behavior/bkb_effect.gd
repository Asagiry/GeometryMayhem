extends SpecialEffectBehavior


func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	receiver.clear_effects(Util.EffectPositivity.NEGATIVE)
	receiver.set_leave_stun_state()


func end() -> void:
	_receiver.effect_ended.emit(Util.EffectType.BKB)
	_receiver.active_special_states.erase(_effect.effect_type)
	super.end()
