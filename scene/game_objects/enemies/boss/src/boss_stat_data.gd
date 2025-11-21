class_name BossStatData

extends Resource

@export_group("HP")
@export var tentacle_max_hp: float
@export var tentacle_regen:float
@export var body_max_hp: float
@export var body_regen: float

@export_group("Resistance")
@export var tentacle_armor: float
@export var body_armor: float

@export_group("Movement")
@export var max_speed: float
@export var acceleration: float
@export var rotation_speed: float

@export_group("Currency")
@export var knowledge_count: int
@export var echo_chance: float
@export var echo_count: int
@export var impulse_count: int
