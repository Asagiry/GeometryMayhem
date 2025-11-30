class_name GifGloveAttackConfig

extends BaseAttackConfig

@export_category("GifGlove Parameters")
## Урон от одного снаряда.
@export var damage: DamageData = DamageData.new()
## Скорость снаряда.
@export var projectile_speed: float = 200.0
## Размер снаряда, изменяется animated_sprite_2d.scale.
@export var projectile_size: float = 1.0
## Коэффициент "силы" предсказания.
## 1.0 = идеальная математическая точность (пытается попасть точно)
## < 1.0 = недолет по упреждению, > 1.0 = перелет (для усложнения)
@export var prediction_accuracy: float = 1.0
## Количество пуль в очереди. Если shots_per_burst = 1, значит выстрел всего 1.
## Если shots_per_burst > 1, то выстреливается очередь с задержкой между выстрелами
## в очереди равной const BURST_DELAY в GifGloveAttackController.
@export var shots_per_burst: int = 1
## Внутренний кулдаун для параллельного исполнения атаки.
@export var cooldown_time: float = 3.0

func get_parameters_dict() -> Dictionary:
	var parameters = super.get_parameters_dict()
	parameters["damage"] = damage
	parameters["projectile_speed"] = projectile_speed
	parameters["projectile_size"] = projectile_size
	parameters["prediction_accuracy"] = prediction_accuracy
	parameters["shots_per_burst"] = shots_per_burst
	parameters["cooldown_time"] = cooldown_time
	return parameters
