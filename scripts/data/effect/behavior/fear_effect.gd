extends SpecialEffectBehavior

const REVERSE_DIRECTION: float = -1.0
const NORMAL_DIRECTION: float = 1.0

func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	receiver.set_direction_modifier(REVERSE_DIRECTION)


func end() -> void:
	_receiver.effect_ended.emit(Util.EffectType.FEAR)
	_receiver.set_direction_modifier(NORMAL_DIRECTION)
	_receiver.active_special_states.erase(_effect.effect_type)
	super.end()
