class_name Tentacle
extends CharacterBody2D

signal tentacle_died(id: int)
signal tentacle_health_changed(current_health, max_health, id: int)

@export var effect_receiver: EffectReceiver
@export var stats: TentacleStatData

@export var damage_interval: float = 0.5
@export var knockback_force: float = 1000.0

var id: int
var damage_timer: Timer
var targets_in_range: Array[Area2D] = []

@onready var health_component: HealthComponent = %HealthComponent
@onready var armor_component: ArmorComponent = %ArmorComponent
@onready var hit_box_component: HitBoxComponent = %HitBoxComponent

func _ready() -> void:
	_setup_timer()
	_connect_signals()


func _setup_timer():
	damage_timer = Timer.new()
	damage_timer.wait_time = damage_interval
	damage_timer.one_shot = false
	damage_timer.timeout.connect(_on_damage_timer_timeout)
	add_child(damage_timer)


func _connect_signals():
	health_component.died.connect(_on_died)
	health_component.health_decreased.connect(_on_health_changed)
	health_component.health_increased.connect(_on_health_changed)
	if not hit_box_component.area_exited.is_connected(_on_hit_box_component_area_exited):
		hit_box_component.area_exited.connect(_on_hit_box_component_area_exited)


func get_effect_receiver():
	return effect_receiver


func get_stats():
	return stats


func get_damage():
	return stats.get_stat("damage_amount")


func _on_health_changed(current_health, max_health):
	tentacle_health_changed.emit(current_health, max_health, id)


func _on_died():
	tentacle_died.emit(id)


func _on_hit_box_component_area_entered(area: Area2D) -> void:
	if area is not HurtBox:
		return
	if not targets_in_range.has(area):
		targets_in_range.append(area)
	_apply_damage_and_knockback(area)
	if damage_timer.is_stopped(): damage_timer.start()


func _on_hit_box_component_area_exited(area: Area2D) -> void:
	if targets_in_range.has(area): targets_in_range.erase(area)
	if targets_in_range.is_empty(): damage_timer.stop()


func _on_damage_timer_timeout() -> void:
	for area in targets_in_range:
		if is_instance_valid(area):
			_apply_damage_and_knockback(area)
		else:
			targets_in_range.erase(area)


func _apply_damage_and_knockback(area: Area2D) -> void:
	if area.has_method("deal_damage"):
		area.deal_damage(DamageData.new(get_damage(), Util.DamageCategory.NONE))
	if owner and area.has_method("apply_effect"):
		area.apply_effect(
			owner.effects,
			owner.stats.magic_find,
			hit_box_component.damage_data
		)
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		if area.owner == player or area.get_parent() == player:
			_push_player(player)


func _push_player(player: Node2D):
	var direction = (player.global_position - global_position).normalized()
	if player.has_method("apply_knockback"):
		player.apply_knockback(direction * knockback_force)
		return
	player.movement_component.velocity += direction * knockback_force
