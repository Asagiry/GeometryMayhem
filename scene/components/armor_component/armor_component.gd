class_name ArmorComponent

extends Node

var armor: float

var armor_multiplier: float = 1.0

var effect_receiver: EffectReceiver

func _ready():
	_enter_varibles()
	_connect_signals()


func _enter_varibles():
	effect_receiver = owner.effect_receiver
	armor = owner.stats.armor


func _connect_signals():
	effect_receiver.armor_component_effects_changed.connect(_on_effect_stats_changed)


func calculate_reduced_damage(damage):
	return snappedf(damage, 0.1)


func _on_effect_stats_changed(updated_stats: Dictionary) -> void:
	if updated_stats.has("armor_multiplier"):
		armor_multiplier = updated_stats["armor_multiplier"]
