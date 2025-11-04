class_name PlayerStatData
extends Resource

signal stat_changed(stat_name: String, old_value, new_value)

var _previous_values: Dictionary = {}

@export_group("HP")
@export var max_health: float
@export var armor: float

@export_group("Movement")
@export var max_speed: float
@export var acceleration: float
@export var rotation_speed: float

@export_group("Dash", "attack")
@export var attack_damage: DamageData
@export var attack_cd: float
@export var attack_duration: float
@export var attack_width: float
@export var attack_range: float

@export_group("Parry", "parry")
@export var parry_damage: DamageData
@export var parry_cd: float
@export var parry_push_distance: float
@export var parry_angle: float
@export var parry_radius: float
@export var parry_duration: float

@export_group("Other")
@export var grace_period_time: float
@export var magic_find: float

# Специальные геттеры для DamageData amount
func get_attack_damage_amount() -> float:
	return attack_damage.amount if attack_damage else 0.0

func set_attack_damage_amount(value: float) -> void:
	if attack_damage:
		var old_value = attack_damage.amount
		attack_damage.amount = value
		stat_changed.emit("attack_damage_amount", old_value, value)

func get_parry_damage_amount() -> float:
	return parry_damage.amount if parry_damage else 0.0

func set_parry_damage_amount(value: float) -> void:
	if parry_damage:
		var old_value = parry_damage.amount
		parry_damage.amount = value
		stat_changed.emit("parry_damage_amount", old_value, value)

# Автообновление через _set
func _set(property: StringName, value) -> bool:
	# Обрабатываем специальные свойства DamageData
	if property == "attack_damage_amount":
		set_attack_damage_amount(value)
		return true
	elif property == "parry_damage_amount":
		set_parry_damage_amount(value)
		return true
	
	# Обычные свойства
	if not property in _previous_values:
		_previous_values[property] = get(property)
	
	var old_value = _previous_values[property]
	if old_value != value:
		_previous_values[property] = value
		set(property, value)
		stat_changed.emit(property, old_value, value)
	return true

# Универсальный get для поддержки специальных свойств
func _get(property: StringName):
	if property == "attack_damage_amount":
		return get_attack_damage_amount()
	elif property == "parry_damage_amount":
		return get_parry_damage_amount()
	
	return null

# Универсальный set_stat для внешнего использования
func set_stat(stat_name: String, value) -> void:
	_set(stat_name, value)

# Универсальный get_stat для внешнего использования  
func get_stat(stat_name: String):
	var result = _get(stat_name)
	if result != null:
		return result
	return get(stat_name)
