class_name EnemyStatData

extends Resource

signal stat_changed(stat_name: String, old_value, new_value)

const DEFAULT_FLOAT_STAT: float = 0.0
const DEFAULT_INT_STAT: int = 0

@export var spawn_point: Vector2

@export_group("HP")
@export var max_health: float
## Раз в секунду добавляет здоровье по такой формуле regeneration * max_health
@export var regeneration: float

@export_group("Resistance")
@export var armor: float

@export_group("Movement")
@export var max_speed: float
@export var acceleration: float
@export var rotation_speed: float

@export_group("Attack", "attack")
@export var attack_damage: DamageData
@export var attack_cd: float
@export var attack_duration: float
## Радиус зоны поражения атаки(ее хит-бокс)
@export var attack_range: float

@export_group("Currency")
@export var knowledge_count: int
@export var echo_chance: float
@export var echo_count: int
@export var impulse_count: int


@export_group("Area Range")
@export var aggro_range: float
## Зона войдя в которую враг начнет атаковать
@export var attack_range_zone: float


@export_group("Range Enemy")
## Задаются значения только для range врага.
@export var projectile_speed: float
## Задаются значения только для range врага.
@export var chance_to_additional_projectile: float

@export_group("Bomb Enemy")
## Задаются значения только для bomb врага.
@export var explosion_delay: float

@export_group("Other")
## Параметр удачи
@export var magic_find: float

var _previous_values: Dictionary = {}

func get_attack_damage_amount() -> float:
	return attack_damage.amount if attack_damage else 0.0


func set_attack_damage_amount(value: float) -> void:
	if attack_damage:
		var old_value = attack_damage.amount
		attack_damage.amount = value
		stat_changed.emit("attack_damage_amount", old_value, value)


func _set(property: StringName, value) -> bool:
	if property == "attack_damage_amount":
		set_attack_damage_amount(value)
		return true

	if not property in _previous_values:
		_previous_values[property] = get(property)

	var old_value = _previous_values[property]
	if old_value != value:
		_previous_values[property] = value
		set(property, value)
		stat_changed.emit(property, old_value, value)
	return true


func _get(property: StringName):
	if property == "attack_damage_amount":
		return get_attack_damage_amount()

	return null


func set_stat(stat_name: String, value) -> void:
	_set(stat_name, value)


func get_stat(stat_name: String):
	var result = _get(stat_name)
	if result != null:
		return result
	return get(stat_name)
