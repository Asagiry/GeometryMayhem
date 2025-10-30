extends SpecialEffectBehavior


func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	receiver.collision_disabled.emit(true)
	print("Phased applied for ", effect.duration, " seconds")

func end() -> void:
	_receiver.collision_disabled.emit(false)
	_receiver.active_special_states[_effect.effect_type] = false
	print("Phased ended")
	super.end()
