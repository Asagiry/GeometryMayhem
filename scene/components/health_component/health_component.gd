class_name HealthComponent

extends Node

signal died
signal health_changed(current_health, max_health)

const ROUNDING_ACCURACY: float = 0.1

var max_health: float = 0.0

var current_health: float
var forward_damage_multiplier: float = 1.0
var invulnerable: bool = false

@onready var armor_component: ArmorComponent
@onready var effect_receiver: EffectReceiver = %EffectReceiver

func _init():
	if owner is EnemyController:
		max_health = owner.stats.max_health
		armor_component = owner.armor_component


func _ready():
	current_health = max_health
	effect_receiver.invulnerability_changed.connect(_on_invulnerability_changed)
	effect_receiver.stats_changed.connect(_on_stats_changed)
	effect_receiver.percent_health_changed.connect(_on_percent_health_changed)

func take_damage(damage: DamageData):
	if invulnerable:
		return

	var final_damage = armor_component.calculate_reduced_damage(
		damage.amount * forward_damage_multiplier,
	)
	current_health = snappedf(max(current_health - final_damage, 0), ROUNDING_ACCURACY)
	emit_signal("health_changed", current_health, max_health)
	if current_health <= 0:
		died.emit()

func _on_invulnerability_changed(status: bool) -> void:
	invulnerable = status


func _on_stats_changed(updated_stats: Dictionary):
	if (updated_stats.has("forward_receiving_damage_multiplier")):
		forward_damage_multiplier = updated_stats["forward_receiving_damage_multiplier"]


func _on_percent_health_changed(updated_value: float, param: bool) -> void:
	if current_health > 0.0:
		if param:
			max_health *= updated_value
			current_health *= updated_value
			return
		max_health /= updated_value
		current_health /= updated_value
