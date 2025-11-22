class_name TentacleStatData

extends Resource

signal stat_changed(stat_name: String, old_value, new_value)

@export_group("HP")
@export var max_health: float
@export var regeneration:float

@export_group("Resistance")
@export var armor: float

@export_group("Currency")
@export var knowledge_count: int
@export var echo_chance: float
@export var echo_count: int
@export var impulse_count: int


var _previous_values: Dictionary = {}

func _set(property: StringName, value) -> bool:
	if not property in _previous_values:
		_previous_values[property] = get(property)

	var old_value = _previous_values[property]
	if old_value != value:
		_previous_values[property] = value
		set(property, value)
		stat_changed.emit(property, old_value, value)
	return true


func set_stat(stat_name: String, value) -> void:
	_set(stat_name, value)


func get_stat(stat_name: String):
	return get(stat_name)
