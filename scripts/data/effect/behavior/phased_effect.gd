extends SpecialEffectBehavior


func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	receiver.collision_disabled.emit(true)

func end() -> void:
	_receiver.effect_ended.emit(Util.EffectType.PHASED)
	_receiver.collision_disabled.emit(false)
	_receiver.active_special_states.erase(_effect.effect_type)
	super.end()
