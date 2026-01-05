extends SpecialEffectBehavior

var _timer: float

func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	_timer = 0.0


func tick(_delta: float) -> void:
	_timer += _delta
	if _timer >= _effect.tick_interval:
		_timer = 0.0
		_receiver.owner.health_component.take_damage(
			DamageData.new(
			_receiver.get_stat("max_health") * _effect.percent,
			Util.DamageCategory.DEFAULT
			)
		)


func end() -> void:
	_receiver.effect_ended.emit(Util.EffectType.WOUNDED)
	_receiver.active_special_states.erase(_effect.effect_type)
	super.end()
