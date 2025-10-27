class_name HealthComponent

extends Node

signal died
signal health_changed(current_health, max_health)

const ROUNDING_ACCURACY: float = 0.1

@export var max_health: float = 0

var current_health: float
var forward_damage_multiplier: float = 1.0
var invulnerable: bool = false

@onready var armor_component: ArmorComponent = %ArmorComponent
@onready var effect_receiver: EffectReceiver = %EffectReceiver


func _ready():
	current_health = max_health
	effect_receiver.invulnerability_changed.connect(_on_invulnerability_changed)

func take_damage(damage: DamageData):
	if invulnerable:
		return

	var final_damage = armor_component.calculate_reduced_damage(
		damage.amount * forward_damage_multiplier,
	)
	current_health = snappedf(max(current_health - final_damage, 0), ROUNDING_ACCURACY)
	emit_signal("health_changed", current_health, max_health)
	#print(owner, "=", current_health)
	if current_health <= 0:
		died.emit()

func _on_invulnerability_changed(status: bool) -> void:
	invulnerable = status
