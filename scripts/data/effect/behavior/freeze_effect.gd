extends SpecialEffectBehavior

const FREEZING_TIME: float = 7.0  # сколько секунд идёт замедление

var input_disabled := true

func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	print("❄ Freeze applied for ", effect.duration, " seconds")

func tick(delta: float) -> void:
	_elapsed_time += delta

	if _elapsed_time < FREEZING_TIME:
		var progress = clampf(_elapsed_time / FREEZING_TIME, 0.0, 1.0)
		var new_speed = 1.0 - progress
		_receiver.set_speed_multiplier(new_speed)
		return

	_receiver.set_speed_multiplier(0.0)
	_receiver.emit_signal("input_disabled", true)

func end() -> void:
	_receiver.set_speed_multiplier(1.0)
	_receiver.emit_signal("input_disabled", false)
	print("🔥 Freeze ended")
	_receiver.active_special_states[_effect.effect_type] = false
	super.end()
