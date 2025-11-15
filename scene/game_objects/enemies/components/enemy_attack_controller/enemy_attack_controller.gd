class_name EnemyAttackController

extends BaseComponent

signal attack_started
signal attack_finished
signal attack_cd_timeout

@export var attack_scene: PackedScene

var attack_range_multiplier: float = 1.0
var attack_duration_multiplier: float = 1.0
var damage_multiplier: float = 1.0
var attack_cd_multiplier: float = 1.0

@onready var cooldown_timer: Timer = $CooldownTimer

func _ready():
	super()
	_connect_signals()

func _connect_signals():
	owner.effect_receiver.attack_component_effects_changed.connect(_on_effect_stats_changed)


func activate_attack():
	pass


func _set_damage(attack_instance):
	attack_instance.hit_box_component.damage_data = get_attack_damage()
	attack_instance.hit_box_component.damage_data.amount *= damage_multiplier


func _create_attack_instance():
	pass


func _get_direction_to_player():
	return (_get_player_position() - owner.global_position).normalized()


func _get_player_position() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		return player.global_position
	return Vector2.ZERO


func start_cooldown():
	cooldown_timer.start(get_cooldown())


func get_duration() -> float:
	return get_stat("attack_duration") * attack_duration_multiplier


func get_cooldown() -> float:
	return get_stat("attack_cd") * attack_cd_multiplier


func get_attack_range() -> float:
	return get_stat("attack_range") * attack_range_multiplier


func get_attack_damage() -> DamageData:
	return get_stat("attack_damage")


func get_projectile_speed() -> float:
	return get_stat("projectile_speed")


func get_chance_to_additional_projectile() -> float:
	return get_stat("chance_to_additional_projectile")


func _on_effect_stats_changed(updated_stats) -> void:
	if updated_stats.has("attack_duration_multiplier"):
		attack_duration_multiplier = updated_stats["attack_duration_multiplier"]
	if updated_stats.has("attack_multiplier"):
		damage_multiplier = updated_stats["attack_multiplier"]
	if updated_stats.has("attack_cd_multiplier"):
		attack_cd_multiplier = updated_stats["attack_cd_multiplier"]
	if updated_stats.has("attack_range_multiplier"):
		attack_range_multiplier = updated_stats["attack_range_multiplier"]
