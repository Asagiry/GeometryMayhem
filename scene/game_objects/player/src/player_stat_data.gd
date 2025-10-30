class_name PlayerStatData

extends Resource

const DEFAULT_FLOAT_STAT: float = 0.0
const DEFAULT_INT_STAT: int = 0

@export var grace_period_time: float

@export var max_health: float
@export var armor: float

@export var max_speed: float
@export var acceleration: float
@export var rotation_speed: float

@export var attack_damage: DamageData
@export var attack_cd: float
@export var attack_duration: float
@export var attack_width: float
@export var attack_range: float

@export var parry_damage: DamageData
@export var parry_cd: float
@export var parry_push_distance: float
@export var parry_angle: float
@export var parry_radius: float
@export var parry_duration: float

@export var magic_find: float

#func _init(
	#p_grace_period_time: float = DEFAULT_FLOAT_STAT,
	#p_max_health: float = DEFAULT_FLOAT_STAT,
	#p_armor: float = DEFAULT_FLOAT_STAT,
	#p_max_speed: float = DEFAULT_FLOAT_STAT,
	#p_acceleration: float = DEFAULT_FLOAT_STAT,
	#p_rotation_speed: float = DEFAULT_FLOAT_STAT,
	#p_attack_damage: DamageData = null,
	#p_attack_cd: float = DEFAULT_FLOAT_STAT,
	#p_attack_duration: float = DEFAULT_FLOAT_STAT,
	#p_attack_width: float = DEFAULT_FLOAT_STAT,
	#p_attack_range: float = DEFAULT_FLOAT_STAT,
	#p_parry_damage: DamageData = null,
	#p_parry_cd: float = DEFAULT_FLOAT_STAT,
	#p_parry_push_distance: float = DEFAULT_FLOAT_STAT,
	#p_parry_angle: float = DEFAULT_FLOAT_STAT,
	#p_parry_radius: float = DEFAULT_FLOAT_STAT,
	#p_parry_duration: float = DEFAULT_FLOAT_STAT,
	#p_magic_find: float = DEFAULT_FLOAT_STAT
#) -> void:
	#grace_period_time = p_grace_period_time
	#max_health = p_max_health
	#armor = p_armor
	#max_speed = p_max_speed
	#acceleration = p_acceleration
	#rotation_speed = p_rotation_speed
	#attack_damage = p_attack_damage
	#attack_cd = p_attack_cd
	#attack_duration = p_attack_duration
	#attack_width = p_attack_width
	#attack_range = p_attack_range
	#parry_damage = p_parry_damage
	#parry_cd = p_parry_cd
	#parry_push_distance = p_parry_push_distance
	#parry_angle = p_parry_angle
	#parry_radius = p_parry_radius
	#parry_duration = p_parry_duration
	#magic_find = p_magic_find
