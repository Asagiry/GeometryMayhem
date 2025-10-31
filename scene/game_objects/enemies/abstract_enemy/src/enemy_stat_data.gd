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

@export var attack_damage: DamageData
@export var attack_cd: float
@export var attack_duration: float

@export var knowledge_count: float
@export var echo_chance: float
@export var echo_count: int
@export var impulse_count: float

@export var aggro_range: float
@export var attack_range: float
@export var attack_range_zone: float
@export var projectile_speed: float
