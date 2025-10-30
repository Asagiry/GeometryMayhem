extends SpecialEffectBehavior

var _attack_source
var _timer: float

func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	var source = effect.source
	_timer = 0.0
	print(source)
	if source:
		_attack_source = source


func tick(_delta: float) -> void:
	_timer += _delta
	if _timer >= _effect.tick_interval:
		_timer = 0.0
		_effect.damage.amount = _effect.percent * _attack_source.stats.attack_damage.amount
		_receiver.owner.health_component.take_damage(
			_effect.damage
		)
		print("damage = ", _effect.damage.amount)


func end() -> void:
	_receiver.active_special_states.erase(_effect.effect_type)
	super.end()
