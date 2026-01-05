extends SpecialEffectBehavior

const FREEZING_TIME: float = 4.0  # сколько секунд идёт замедление
const ATTACK_DURATION_MULTIPLIER: float = 2
const DEFAULT_MULTIPLIER: float = 1.0

var setted: bool = false



func apply(receiver: EffectReceiver, effect: Effect) -> void:
	super.apply(receiver, effect)

func tick(_delta: float) -> void:
	if _elapsed_time < FREEZING_TIME:
		var relation = _elapsed_time / FREEZING_TIME
		var progress = clampf(_elapsed_time / FREEZING_TIME, 0.0, 1.0)
		var speed_multiplier = 1.0 - progress
		var new_base_multiplier = (ATTACK_DURATION_MULTIPLIER + progress) * ATTACK_DURATION_MULTIPLIER
		_receiver.owner.movement_component.set_freeze_multiplier(speed_multiplier)
		_receiver.set_attack_duration_multiplier(new_base_multiplier)
		return

	if !setted:
		_receiver.set_stun_state(_effect.duration - FREEZING_TIME)
		setted = true


func end() -> void:
	_receiver.set_attack_duration_multiplier(DEFAULT_MULTIPLIER)
	_receiver.owner.movement_component.set_freeze_multiplier(DEFAULT_MULTIPLIER)
	_receiver.active_special_states.erase(_effect.effect_type)
	_receiver.effect_ended.emit(Util.EffectType.FREEZE)
	super.end()
