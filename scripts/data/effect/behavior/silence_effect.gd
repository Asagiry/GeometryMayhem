extends SpecialEffectBehavior


func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	receiver.silenced.emit(true)
	print("Silence applied for ", effect.duration, " seconds")


func end() -> void:
	_receiver.silenced.emit(false)
	_receiver.effect_ended.emit(Util.EffectType.SILENCE)
	_receiver.active_special_states[_effect.effect_type] = false
	print("Silence ended")
	super.end()
