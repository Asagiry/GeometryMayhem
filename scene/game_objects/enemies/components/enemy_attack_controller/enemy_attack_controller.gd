class_name EnemyAttackController

extends Node

signal attack_started
signal attack_finished
signal attack_cd_timeout

@export var attack_scene: PackedScene

var attack_damage: DamageData = DamageData.new()
var attack_duration: float
var attack_cd: float
var attack_range: float
var projectile_speed: float

var attack_range_multiplier: float
var attack_duration_multiplier: float = 1.0
var damage_multiplier: float = 1.0
var attack_cd_multiplier: float = 1.0

@onready var cooldown_timer: Timer = $CooldownTimer

func _ready():
	_enter_variables()
	_connect_signals()


func _enter_variables():
	attack_damage = owner.stats.attack_damage
	attack_duration = owner.stats.attack_duration
	attack_cd = owner.stats.attack_cd
	attack_range = owner.stats.attack_range
	projectile_speed = owner.stats.projectile_speed


func _connect_signals():
	owner.effect_receiver.attack_component_effects_changed.connect(_on_effect_stats_changed)


func activate_attack():
	pass


func _set_damage(attack_instance):
	attack_instance.hit_box_component.damage_data = attack_damage


func _create_attack_instance():
	pass


func start_cooldown():
	cooldown_timer.start(get_cooldown())


func get_duration():
	return attack_duration * attack_duration_multiplier


func get_cooldown():
	return attack_cd * attack_cd_multiplier

func get_attack_range():
	return attack_range * attack_range_multiplier


func _on_effect_stats_changed(updated_stats) -> void:
	if updated_stats.has("attack_duration_multiplier"):
		attack_duration_multiplier = updated_stats["attack_duration_multiplier"]
	if updated_stats.has("attack_multiplier"):
		damage_multiplier = updated_stats["attack_multiplier"]
	if updated_stats.has("attack_cd_multiplier"):
		attack_cd_multiplier = updated_stats["attack_cd_multiplier"]
