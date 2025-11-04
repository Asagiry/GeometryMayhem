class_name ResonanceStatData

extends Resource


@export_group("HP")
@export var max_health_multiplier: float = 1.0
@export var armor_multiplier: float = 1.0

@export_group("Movement")
@export var max_speed_multiplier: float = 1.0
@export var acceleration_multiplier: float = 1.0
@export var rotation_speed_multiplier: float = 1.0

@export_group("Dash", "attack")
@export var attack_damage_multiplier: float = 1.0
@export var attack_cd_multiplier: float = 1.0
@export var attack_duration_multiplier: float = 1.0
@export var attack_width_multiplier: float = 1.0
@export var attack_range_multiplier: float = 1.0

@export_group("Parry", "parry")
@export var parry_damage_multiplier: float = 1.0
@export var parry_cd_multiplier: float = 1.0
@export var parry_push_distance_multiplier: float = 1.0
@export var parry_angle_multiplier: float = 1.0
@export var parry_radius_multiplier: float = 1.0
@export var parry_duration_multiplier: float = 1.0

@export_group("Other")
@export var grace_period_time_multiplier: float = 1.0
@export var magic_find_multiplier: float = 1.0 #удача


const STAT_MAPPINGS: Array[Array] = [
	# HP
	["max_health_multiplier", "max_health"],
	["armor_multiplier", "armor"],
	
	# Movement
	["max_speed_multiplier", "max_speed"],
	["acceleration_multiplier", "acceleration"],
	["rotation_speed_multiplier", "rotation_speed"],
	
	# Attack
	["attack_damage_multiplier", "attack_damage_amount"],
	["attack_cd_multiplier", "attack_cd"],
	["attack_duration_multiplier", "attack_duration"],
	["attack_width_multiplier", "attack_width"],
	["attack_range_multiplier", "attack_range"],
	
	# Parry
	["parry_damage_multiplier", "parry_damage_amount"],
	["parry_cd_multiplier", "parry_cd"],
	["parry_push_distance_multiplier", "parry_push_distance"],
	["parry_angle_multiplier", "parry_angle"],
	["parry_radius_multiplier", "parry_radius"],
	["parry_duration_multiplier", "parry_duration"],
	
	# Other
	["grace_period_time_multiplier", "grace_period_time"],
	["magic_find_multiplier", "magic_find"]
]

func apply_to_stats(target_stats: Object, apply: bool) -> void:
	for mapping in STAT_MAPPINGS:
		var multiplier_name: String = mapping[0]
		var stat_name: String = mapping[1]
		
		var multiplier: float = get(multiplier_name)
		#TODO убрать проверку, если все статы будут увеличиваться
		if !is_zero_approx(multiplier - 1.0):
			# Используем get_stat вместо get для поддержки специальных свойств
			var current_value = target_stats.get_stat(stat_name)

			# Проверяем что current_value не nil и является числом
			if current_value == null:
				push_error("Stat %s is null in target_stats" % stat_name)
				continue

			if not (current_value is int or current_value is float):
				push_error("Stat %s is not a number: %s" % [stat_name, str(current_value)])
				continue

			var operation_multiplier = multiplier if apply else 1.0 / multiplier
			var new_value = current_value * operation_multiplier


			target_stats.set_stat(stat_name, new_value)
