extends SpecialEffectBehavior

const FREEZING_TIME: float = 10.0  # сколько секунд идёт замедление
const BASE_DURATION_MULTIPLIER: float = 1.7
const DEFAULT_MULTIPLIER: float = 1.0

var setted: bool = false

func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)
	print("❄ Freeze applied for ", effect.duration, " seconds")

func tick(_delta: float) -> void:
	if _elapsed_time < FREEZING_TIME:
		var progress = clampf(_elapsed_time / FREEZING_TIME, 0.0, 1.0)
		var new_speed_multiplier = 1.0 - progress
		var new_base_multiplier = (BASE_DURATION_MULTIPLIER + progress) * BASE_DURATION_MULTIPLIER
		_receiver.set_speed_multiplier(new_speed_multiplier)
		_receiver.set_attack_duration_multiplier(new_base_multiplier)
		_receiver.set_parry_duration_multiplier(new_base_multiplier)
		return

	if !setted:
		_receiver.set_speed_multiplier(0.0)
		_receiver.input_disabled.emit(true)
		setted = true


func end() -> void:
	_receiver.set_speed_multiplier(DEFAULT_MULTIPLIER)
	_receiver.set_attack_duration_multiplier(DEFAULT_MULTIPLIER)
	_receiver.set_parry_duration_multiplier(DEFAULT_MULTIPLIER)
	_receiver.emit_signal("input_disabled", false)
	print("❄ Freeze ended")
	_receiver.active_special_states[_effect.effect_type] = false
	super.end()
