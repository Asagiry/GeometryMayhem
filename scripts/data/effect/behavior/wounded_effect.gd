extends SpecialEffectBehavior

var _timer: float

func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	_timer = 0.0


func tick(_delta: float) -> void:
	_timer += _delta
	if _timer >= _effect.tick_interval:
		_timer = 0.0
		_effect.damage.amount = _effect.percent * _receiver.owner.stats.max_health
		_receiver.owner.health_component.take_damage(
			_effect.damage
		)


func end() -> void:
	_receiver.active_special_states.erase(_effect.effect_type)
	super.end()
