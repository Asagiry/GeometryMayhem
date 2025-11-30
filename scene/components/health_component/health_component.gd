class_name HealthComponent

extends BaseComponent

signal died
signal health_decreased(current_health, max_health)
signal health_increased(current_health, max_health)

const ROUNDING_ACCURACY: float = 0.1
const DEFAULT_MULTIPLIER: float = 1.0

@export var armor_component: ArmorComponent

var current_health: float
var health_ratio: float = 1.0

var forward_damage_multiplier: float = DEFAULT_MULTIPLIER
var invulnerable: bool = false
var percent_health_multiplier: float = DEFAULT_MULTIPLIER

var effect_receiver: EffectReceiver

func _ready():
	super._ready()
	_connect_signals()


func take_damage(damage: DamageData):
	if invulnerable:
		return

	var final_damage = armor_component.calculate_reduced_damage(
		damage.amount * forward_damage_multiplier,
	)

	var old_health = current_health
	current_health = snappedf(max(current_health - final_damage, 0), ROUNDING_ACCURACY)

	var max_hp = get_max_health()
	if max_hp > 0:
		health_ratio = current_health / max_hp

	health_decreased.emit(current_health, max_hp)

	if current_health <= 0:
		died.emit()


func take_heal(amount_of_heal: float):
	var old_health = current_health
	var max_hp = get_max_health()
	current_health = snappedf(min(current_health + amount_of_heal, max_hp), ROUNDING_ACCURACY)

	if max_hp > 0:
		health_ratio = current_health / max_hp

	health_increased.emit(current_health, max_hp)


func get_max_health() -> float:
	return get_stat("max_health")


func get_current_health() -> float:
	return current_health


func get_health_ratio() -> float:
	return health_ratio


func get_regeneration() -> float:
	return get_stat("regeneration")


func _setup_owner_reference():
	super._setup_owner_reference()

	if owner_node and owner_node.has_method("get_effect_receiver"):
		effect_receiver = owner_node.get_effect_receiver()
	elif _owner_has_property("effect_receiver"):
		effect_receiver = owner_node.effect_receiver

	current_health = get_max_health()


func _setup_stat_subscriptions():
	subscribe_to_stat("max_health", _on_max_health_changed)


func _connect_signals():
	effect_receiver.health_component_effects_changed.connect(_on_effect_stats_changed)


func _on_regeneration_timer_timeout() -> void:
	var regeneration = get_regeneration()
	if regeneration == 0.0:
		return
	take_heal(regeneration * get_max_health())


func _on_effect_stats_changed(updated_stats: Dictionary) -> void:
	if updated_stats.has("forward_receiving_damage_multiplier"):
		forward_damage_multiplier = updated_stats["forward_receiving_damage_multiplier"]

	if updated_stats.has("invulnerable"):
		invulnerable = updated_stats["invulnerable"]

	if updated_stats.has("percent_of_max_health"):
		var percent = updated_stats["percent_of_max_health"]
		if is_zero_approx(percent - DEFAULT_MULTIPLIER):
			owner_stats.set_stat("max_health", get_max_health()  / percent_health_multiplier)
		else:
			owner_stats.set_stat("max_health", get_max_health() * percent)
		percent_health_multiplier = percent


func _on_max_health_changed(new_max_health: float, old_max_health: float):
	if old_max_health <= 0:
		current_health = new_max_health
		health_increased.emit(current_health, new_max_health)
		return

	var health_percentage = current_health / old_max_health
	current_health = health_percentage * new_max_health

	health_increased.emit(current_health, new_max_health)

	print("Max health updated: %d -> %d, Current: %d (%.1f%%)" % [
		old_max_health, new_max_health, current_health, health_percentage * 100
	])
