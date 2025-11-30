class_name GifGloveAttackScene

extends Node2D

const LIFETIME_OF_PROJECTILE: float = 10.0

var projectile_speed: float = 200.0

var direction: Vector2 = Vector2.ZERO
var effects: Array[Effect]
var magic_find: float

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var queue_free_timer: Timer = %QueueFreeTimer


func _ready() -> void:
	queue_free_timer.start(LIFETIME_OF_PROJECTILE)


func _physics_process(delta: float) -> void:
	position += projectile_speed * direction * delta


func set_parameters(
	p_projectile_speed,
	p_projectile_size,
	p_direction,
):
	projectile_speed = p_projectile_speed
	direction = p_direction
	_set_projectile_size(p_projectile_size)


func set_enemy(p_enemy):
	effects = p_enemy.effects
	magic_find = p_enemy.stats.magic_find


func _set_projectile_size(projectile_size):
	animated_sprite_2d.scale = Vector2(projectile_size, projectile_size)


func set_damage(damage_data: DamageData):
	hit_box_component.damage_data = damage_data


func _on_hit_box_component_area_entered(area: Area2D) -> void:
	if area is not HurtBox:
		return
	if area.has_method("deal_damage"):
		area.deal_damage(hit_box_component.damage_data)
	if area.has_method("apply_effect"):
		area.apply_effect(
			effects,
			magic_find,
			hit_box_component.damage_data
		)
	queue_free()


func _on_queue_free_timer_timeout() -> void:
	queue_free()
