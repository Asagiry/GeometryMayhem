class_name ResonanceComponentData

extends Resource

@export_group("Base")
## Умножение получаемого импульса
@export var impulse_multiplier: float
## Максимальный уровень резонанса
@export var max_level: int
## Уровень ниже которого нельзя опустится. Пример: Если safe_level = 5, то
##каждый пятый уровень считается безопасным.
@export var safe_level: int

@export_group("Impulse Decrease")

@export_subgroup("Hit")
## Процент потери импульса при получении урона (0-1)
@export_range(0.0, 1.0) var impulse_percent_decrease_for_hit: float

@export_subgroup("Afk")
## Добавочный процент к минимального проценту потери, добавляется пока
## процент потери не дойдет до максимального
@export_range(0.0, 1.0) var addition_percent: float
## Минимальный процент потери импульса при afk
@export_range(0.0, 1.0) var min_decrease_percent: float
## Максимальный процент потери импульса при afk
@export_range(0.0, 1.0) var max_decrease_percent: float

@export_group("Timers")
## Время возможного бездействия после прошествии которого игрок начнет
## терять импульс
@export var impulse_loss_delay: float
## Раз в какое время игрок теряет импульс после того, как таймер бездействия
## прошел
@export var impulse_loss_timer_tick: float


@export_group("Impulse level")
## Количество импульса для перехода с 0 -> 1 уровня
@export var base_impulse_requirement: int = 100
## Насколько растёт требование за каждый новый уровень
@export var impulse_increment: int = 100
## Увеличение прироста после каждого safe уровня
@export var tier_increment: int = 100

func get_required_impulse(current_level: int) -> int:
	@warning_ignore("integer_division")
	var tier = current_level / safe_level
	return base_impulse_requirement + current_level * impulse_increment \
	+ tier * tier_increment
