extends SpecialEffectBehavior


func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	receiver.input_disabled.emit(true)
	print("Silence applied for ", effect.duration, " seconds")


func end() -> void:
	_receiver.input_disabled.emit(false)
	_receiver.active_special_states[_effect.effect_type] = false
	print("Silence ended")
	super.end()
