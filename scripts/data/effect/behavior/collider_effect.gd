extends SpecialEffectBehavior

func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	receiver.owner.collision_layer |= 1 << 0

func end() -> void:
	_receiver.owner.collision_layer &= ~(1 << 0)
	super.end()
