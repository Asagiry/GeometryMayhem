class_name ArmorComponent

extends BaseComponent

var armor_multiplier: float = 1.0
var effect_receiver: EffectReceiver


func _ready():
	super._ready()  # Вызовет _setup_owner_reference() и _setup_stat_subscriptions()
	_connect_signals()


func calculate_reduced_damage(damage: float) -> float:
	var current_armor = get_armor() * armor_multiplier
	var reduced_damage = _apply_armor_formula(damage, current_armor)
	return snappedf(reduced_damage, 0.1)


func get_armor() -> float:
	return get_stat("armor") * armor_multiplier


func _connect_signals():
	if effect_receiver:
		effect_receiver.armor_component_effects_changed.connect(_on_effect_stats_changed)


func _setup_owner_reference():
	super._setup_owner_reference()
	if owner_node and owner_node.has_method("get_effect_receiver"):
		effect_receiver = owner_node.get_effect_receiver()
	elif _owner_has_property("effect_receiver"):
		effect_receiver = owner_node.effect_receiver


func _apply_armor_formula(damage: float, _armor: float) -> float:
	# 🔧 Здесь можно реализовать любую формулу снижения урона
	# Пример 1: Процентное снижение (максимум 80%)
	# var damage_reduction = min(armor / (armor + 100), 0.8)
	# return damage * (1.0 - damage_reduction)

	# Пример 2: Плоское снижение
	# return max(damage - armor, damage * 0.1)  # Минимум 10% урона

	# Пример 3: Гибридная формула
	#var flat_reduction = get_armor() * 0.5
	#var percentage_reduction = min(armor * 0.01, 0.6)  # Максимум 60%
	#var after_flat = max(damage - flat_reduction, 0)
	#return after_flat * (1.0 - percentage_reduction)
	return damage


func _on_effect_stats_changed(updated_stats: Dictionary) -> void:
	if updated_stats.has("armor_multiplier"):
		armor_multiplier = updated_stats["armor_multiplier"]
