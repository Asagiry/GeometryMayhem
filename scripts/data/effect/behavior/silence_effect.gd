extends SpecialEffectBehavior

var input_disabled: bool = true

func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	receiver.input_disabled.emit(input_disabled)
	input_disabled = false
	print("Silence applied for ", effect.duration, " seconds")


func end() -> void:
	_receiver.input_disabled.emit(input_disabled)
	_receiver.active_special_states[_effect.effect_type] = false
	print("Silence ended")
	super.end()
