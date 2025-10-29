class_name EnemyStatData

extends Resource

const DEFAULT_FLOAT_STAT: float = 0.0
const DEFAULT_INT_STAT: int = 0

@export var spawn_point: Vector2

@export var max_health: float
@export var armor: float

@export var max_speed: float
@export var acceleration: float
@export var rotation_speed: float

@export var attack_damage: float
@export var attack_cd: float
@export var attack_duration: float

@export var knowledge_count: float
@export var echo_chance: float
@export var echo_count: int
@export var impulse_count: float

@export var aggro_range: float
@export var attack_range: float


func _init(
	p_spawn_point: Vector2 = Vector2.ZERO,
	p_max_health: float = DEFAULT_FLOAT_STAT,
	p_armor: float = DEFAULT_FLOAT_STAT,
	p_max_speed: float = DEFAULT_FLOAT_STAT,
	p_acceleration: float = DEFAULT_FLOAT_STAT,
	p_rotation_speed: float = DEFAULT_FLOAT_STAT,
	p_attack_damage: float = DEFAULT_FLOAT_STAT,
	p_attack_cd: float = DEFAULT_FLOAT_STAT,
	p_attack_duration: float = DEFAULT_FLOAT_STAT,
	p_knowledge_count: float = DEFAULT_FLOAT_STAT,
	p_echo_chance: float = DEFAULT_FLOAT_STAT,
	p_echo_count: int = DEFAULT_INT_STAT,
	p_impulse_count: float = DEFAULT_FLOAT_STAT,
	p_aggro_range: float = DEFAULT_FLOAT_STAT,
	p_attack_range: float = DEFAULT_FLOAT_STAT
) -> void:
	spawn_point = p_spawn_point
	max_health = p_max_health
	armor = p_armor
	max_speed = p_max_speed
	acceleration = p_acceleration
	rotation_speed = p_rotation_speed
	attack_damage = p_attack_damage
	attack_cd = p_attack_cd
	attack_duration = p_attack_duration
	knowledge_count = p_knowledge_count
	echo_chance = p_echo_chance
	echo_count = p_echo_count
	impulse_count = p_impulse_count
	aggro_range = p_aggro_range
	attack_range = p_attack_range
