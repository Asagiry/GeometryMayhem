extends SpecialEffectBehavior

var last_position: Vector2

func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	last_position = receiver.player.global_position
	print("🩸 Rupture applied for ", effect.duration, " seconds")

func tick(delta: float) -> void:
	var current_position = _receiver.player.global_position
	var distance_moved = current_position.distance_to(last_position)

	if distance_moved > 0.01:
		var damage = _effect.damage.duplicate()
		damage.amount *= distance_moved
		_receiver.health_component.take_damage(damage)
		last_position = current_position

func end() -> void:
	_receiver.active_special_states[_effect.effect_type] = false
	print("🩸 Rupture ended")
	super.end()
