class_name RangeEnemyAttackScene1

extends Node2D

const LIFETIME_OF_PROJECTILE: float = 6.0

var projectile_speed: float = 200.0
var direction: Vector2 = Vector2.ZERO
var effects

@onready var hit_box_component = %HitBoxComponent
@onready var queue_free_timer: Timer = $QueueFreeTimer

func _ready() -> void:
	queue_free_timer.start(LIFETIME_OF_PROJECTILE)


func _physics_process(delta: float) -> void:
	position += projectile_speed * direction * delta


func _on_hit_box_component_area_entered(area: Area2D) -> void:
	if area is not HurtBox:
		return
	if area.has_method("deal_damage"):
		area.deal_damage(hit_box_component.damage_data)
	if area.has_method("apply_effect"):
		area.apply_effect(effects)
	queue_free()


func change_collision():
	hit_box_component.set_collision_mask_value(9, false)
	hit_box_component.set_collision_mask_value(8, true)


func set_enemy(p_enemy: EnemyController):
	effects = p_enemy.effects.duplicate()


func set_projectile_speed(p_projectile_speed):
	projectile_speed = p_projectile_speed


func set_direction(p_direction):
	direction = p_direction


func _on_queue_free_timer_timeout() -> void:
	queue_free()
