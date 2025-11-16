class_name StatModifierData

extends Resource

const MAX_MULTIPLIER: float = 10.0
const DEFAULT_MULTIPLIER: float = 1.0
const MIN_MULTIPLIER: float = 0.0

@export_group("Attack Comp Mults", "attack")
@export var attack_multiplier: float = DEFAULT_MULTIPLIER
@export var attack_cd_multiplier: float = DEFAULT_MULTIPLIER
@export var attack_duration_multiplier: float = DEFAULT_MULTIPLIER
@export var attack_range_multiplier: float = DEFAULT_MULTIPLIER

@export_group("Movement Comp Mults")
@export var speed_multiplier: float = DEFAULT_MULTIPLIER

@export_group("Armor Comp Mults")
@export var armor_multiplier: float = DEFAULT_MULTIPLIER

@export_group("Health Comp Mults")
@export var forward_receiving_damage_multiplier: float = DEFAULT_MULTIPLIER
@export var invulnerable: bool
@export var percent_of_max_health: float = DEFAULT_MULTIPLIER

# ——— внутренние поля для итерации
var _iter_index := 0
var _iter_filtered: Array = []

# Список всех экспортируемых полей (можно автоматизировать, но лучше явно)
var _fields := [
	"speed_multiplier",
	"attack_multiplier",
	"armor_multiplier",
	"forward_receiving_damage_multiplier",
	"attack_cd_multiplier",
	"attack_duration_multiplier",
	"invulnerable",
	"percent_of_max_health",
	"attack_range_multiplier"
]


func reset() -> void:
	speed_multiplier = DEFAULT_MULTIPLIER
	attack_multiplier = DEFAULT_MULTIPLIER
	armor_multiplier = DEFAULT_MULTIPLIER
	forward_receiving_damage_multiplier = DEFAULT_MULTIPLIER
	attack_cd_multiplier = DEFAULT_MULTIPLIER
	attack_duration_multiplier = DEFAULT_MULTIPLIER
	percent_of_max_health = DEFAULT_MULTIPLIER


func set_speed_multiplier(value: float) -> void:
	speed_multiplier = clampf(value, MIN_MULTIPLIER, MAX_MULTIPLIER)


func set_attack_multiplier(value: float) -> void:
	attack_multiplier = clampf(value, MIN_MULTIPLIER, MAX_MULTIPLIER)


func set_armor_multiplier(value: float) -> void:
	armor_multiplier = clampf(value, MIN_MULTIPLIER, MAX_MULTIPLIER)


func set_forward_receiving_damage_multiplier(value: float) -> void:
	forward_receiving_damage_multiplier = \
	clampf(
		value,
		MIN_MULTIPLIER,
		MAX_MULTIPLIER
		)


func set_attack_cd_multiplier(value: float) -> void:
	attack_cd_multiplier = clampf(value, MIN_MULTIPLIER, MAX_MULTIPLIER)


func set_attack_duration_multiplier(value: float) -> void:
	attack_duration_multiplier = clampf(value, MIN_MULTIPLIER, MAX_MULTIPLIER)


func set_invulnerable(value: bool) -> void:
	invulnerable = value


func set_percent_of_max_health_multiplier(value: float) -> void:
	percent_of_max_health = clampf(value, MIN_MULTIPLIER, MAX_MULTIPLIER)


func set_attack_range_multiplier(value: float) -> void:
	attack_range_multiplier = clampf(value, MIN_MULTIPLIER, MAX_MULTIPLIER)


func to_dict() -> Dictionary:
	var result := {}
	for name in _fields:
		result[name] = get(name)
	return result


func _iter_init(_arg):
	_iter_filtered.clear()
	for name in _fields:
		var value = get(name)
		var t = typeof(value)
		# пропускаем float == 1.0
		if t == TYPE_FLOAT and is_equal_approx(value, DEFAULT_MULTIPLIER):
			continue
		_iter_filtered.append(name)
	_iter_index = 0
	return _iter_index < _iter_filtered.size()


func _iter_next(_arg):
	_iter_index += 1
	return _iter_index < _iter_filtered.size()


func _iter_get(_arg):
	return _iter_filtered[_iter_index]
