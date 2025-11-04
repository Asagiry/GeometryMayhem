class_name ResonanceComponent

extends Node

signal impulse_amount_changed(current_impulse: int)

const SINGLE_LEVEL: int = 1

@export var player: PlayerController
@export var resonance_data: ResonanceComponentData
@export var resonance_stat_data: ResonanceStatData

var current_impulse: int = 0
var current_level: int = 0
var loss_timer_counter: int = 0

@onready var health_component: HealthComponent = %HealthComponent
@onready var afk_timer: Timer = $AfkTimer
@onready var loss_timer: Timer = $LossTimer

func _ready():
	Global.enemy_died.connect(_on_enemy_died)
	Global.player_damage_done.connect(_on_damage_done)
	health_component.health_decreased.connect(_on_health_decreased)
	afk_timer.wait_time = resonance_data.impulse_loss_delay
	loss_timer.wait_time = resonance_data.impulse_loss_timer_tick


func _is_max_level() -> bool:
	return current_level == resonance_data.max_level


func _is_at_safe_level() -> bool:
	return current_level % resonance_data.safe_level == 0


func _has_no_impulse() -> bool:
	return current_impulse == 0


func _can_increase_level() -> bool:
	return not _is_max_level()


func _can_decrease_level() -> bool:
	return current_level > 0 and not _is_at_safe_level()


func _should_skip_decrease() -> bool:
	return _is_at_safe_level() and _has_no_impulse()


func _update_impulse_display():
	Global.impulse_amount_changed.emit(
		current_impulse,
		current_level,
		resonance_data.get_required_impulse(current_level)
	)

func _increase_impulse(value: int):
	if not _can_increase_level():
		return

	current_impulse += int(value * resonance_data.impulse_multiplier)
	var required_impulse = resonance_data.get_required_impulse(current_level)

	while current_impulse >= required_impulse and _can_increase_level():
		_decrease_impulse(required_impulse)
		_increase_level()

		if _is_max_level():
			break
		required_impulse = resonance_data.get_required_impulse(current_level)
	
	_update_impulse_display()


func _decrease_impulse(value: int):
	if _should_skip_decrease():
		return

	current_impulse -= value

	if current_impulse <= 0:
		if not _can_decrease_level():
			current_impulse = 0
			_update_impulse_display()
			return

		_decrease_level()
		_increase_impulse(resonance_data.get_required_impulse(current_level))

	_update_impulse_display()


func _increase_level():
	current_level += SINGLE_LEVEL
	resonance_stat_data.apply_to_stats(player.stats, true)


func _decrease_level():
	current_level -= SINGLE_LEVEL
	resonance_stat_data.apply_to_stats(player.stats, false)


func _loss_timer_stop():
	loss_timer.stop()
	loss_timer_counter = 0


func _on_enemy_died(stats: EnemyStatData):
	_loss_timer_stop()
	afk_timer.start()
	_increase_impulse(stats.impulse_count)


func _on_health_decreased(_current_health: int, _max_health: int):
	_loss_timer_stop()
	afk_timer.start()
	_decrease_impulse(
		int(resonance_data.impulse_percent_decrease_for_hit *\
		resonance_data.get_required_impulse(current_level))
	)


func _on_damage_done():
	_loss_timer_stop()
	afk_timer.start()


func _on_afk_timer_timeout() -> void:
	if _is_at_safe_level() and _has_no_impulse():
		return

	loss_timer.start()
	_decrease_impulse(
		int(resonance_data.min_decrease_percent *\
		resonance_data.get_required_impulse(current_level))
	)


func _on_loss_timer_timeout() -> void:
	if _is_at_safe_level() and _has_no_impulse():
		_loss_timer_stop()
		return

	loss_timer_counter += 1

	var percent_multiplier = resonance_data.min_decrease_percent + \
	resonance_data.addition_percent * loss_timer_counter
	percent_multiplier = min(percent_multiplier, resonance_data.max_decrease_percent)

	_decrease_impulse(
		int(percent_multiplier * resonance_data.get_required_impulse(current_level))
	)
