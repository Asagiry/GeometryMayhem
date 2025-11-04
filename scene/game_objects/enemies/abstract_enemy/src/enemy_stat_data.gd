class_name EnemyStatData

extends Resource

const DEFAULT_FLOAT_STAT: float = 0.0
const DEFAULT_INT_STAT: int = 0

@export var spawn_point: Vector2

@export_group("HP")
@export var max_health: float
@export var armor: float

@export_group("Movement")
@export var max_speed: float
@export var acceleration: float
@export var rotation_speed: float

@export_group("Attack")
@export var attack_damage: DamageData
@export var attack_cd: float
@export var attack_duration: float

@export_group("Currency")
@export var knowledge_count: int
@export var echo_chance: float
@export var echo_count: int
@export var impulse_count: int

@export_group("Area Range")
@export var aggro_range: float
## Радиус зоны поражения атаки(ее хит-бокс)
@export var attack_range: float
## Зона войдя в которую враг начнет атаковать
@export var attack_range_zone: float

@export_group("Range Enemy")
@export var projectile_speed: float
@export var chance_to_additional_projectile: float

@export_group("Bomb Enemy")
@export var explosion_delay: float
