extends SpecialEffectBehavior


func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	receiver.input_disabled.emit(true)


func end() -> void:
	_receiver.input_disabled.emit(false)
	_receiver.active_special_states.erase(_effect.effect_type)
	super.end()
