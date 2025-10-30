class_name HealthComponent

extends Node

signal died
signal health_changed(current_health, max_health)

const ROUNDING_ACCURACY: float = 0.1

var max_health: float = 0.0
var current_health: float

var forward_damage_multiplier: float = 1.0
var invulnerable: bool = false

@export var armor_component: ArmorComponent
var effect_receiver: EffectReceiver

func _ready():
	max_health = owner.stats.max_health
	effect_receiver = owner.effect_receiver
	current_health = max_health
	effect_receiver.health_component_effects_changed.connect(_on_effect_stats_changed)

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



func _on_effect_stats_changed(updated_stats: Dictionary) -> void:
	if (updated_stats.has("forward_receiving_damage_multiplier")):
		forward_damage_multiplier = updated_stats["forward_receiving_damage_multiplier"]

	if updated_stats.has("invulnerable"):
		invulnerable = updated_stats["invulnerable"]

	if updated_stats.has("percent_of_max_health"):
		var percent_health_multiplier = updated_stats["percent_of_max_health"]
		max_health *= percent_health_multiplier
		current_health *= percent_health_multiplier
		percent_health_multiplier = 1 / percent_health_multiplier
		#TODO#
		#GOOSE REKA
