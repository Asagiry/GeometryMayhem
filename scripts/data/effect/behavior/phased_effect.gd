extends SpecialEffectBehavior


func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	if receiver.owner.enemy_collision:
		receiver.owner.enemy_collision.disabled = true
	receiver.set_invulnerability(true)
	print("Phased applied for ", effect.duration, " seconds")

func end() -> void:
	_receiver.set_invulnerability(false)
	_receiver.owner.enemy_collision.disabled = false
	_receiver.active_special_states[_effect.effect_type] = false
	print("Phased ended")
	super.end()
