class_name BossHealthComponent

extends BaseComponent

signal tentacle_died(name)
signal health_changed()

const ROUNDING_ACCURACY: float = 0.1
const DEFAULT_MULTIPLIER: float = 1.0

@export var armor_component: BossArmorComponent
@export var effect_receiver: EffectReceiver

var boss: BossController
var current_health: Dictionary = {}
var health_ratio: float = 1.0

var forward_damage_multiplier: float = DEFAULT_MULTIPLIER

func _ready():
	boss = owner
	current_health["T1HurtBox"] = boss.stats.tentacle_max_hp
	current_health["T2HurtBox"] = boss.stats.tentacle_max_hp
	current_health["T3HurtBox"] = boss.stats.tentacle_max_hp
	current_health["T4HurtBox"] = boss.stats.tentacle_max_hp
	current_health["BodyHurtBox"] = boss.stats.tentacle_max_hp


func take_damage(damageData: DamageData,p_name: String):
	var damage = armor_component.calculate_reduced_damage(damageData.amount,p_name)
	current_health[p_name] -= damage
	health_changed.emit(current_health[p_name],p_name)
	if (current_health[p_name] <= 0):
		tentacle_died.emit(p_name)
		current_health.erase(p_name)


func _on_regeneration_timer_timeout() -> void:
	for hurt_box_key: String in current_health.keys():
		if hurt_box_key.contains("T"):
			current_health[hurt_box_key] += boss.stats.tentacle_regen
		else:
			current_health[hurt_box_key] += boss.stats.body_regen

		health_changed.emit(current_health[hurt_box_key],hurt_box_key)
