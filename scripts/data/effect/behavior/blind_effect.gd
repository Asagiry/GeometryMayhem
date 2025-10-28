extends SpecialEffectBehavior

#прелоад vignette
#var vignette = preload("vignette")

func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	#добавить виньетку куда надо
	print("Blind applied for ", effect.duration, " seconds")

func end() -> void:
	#убрать виньетку
	_receiver.active_special_states[_effect.effect_type] = false
	print("Blind ended")
	super.end()
