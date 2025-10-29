extends SpecialEffectBehavior

const HEALTH_MULTIPLIER: float = 2.0

func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	receiver.set_percent_health(HEALTH_MULTIPLIER, true)


func end() -> void:
	_receiver.set_percent_health(HEALTH_MULTIPLIER, false)
	super.end()
