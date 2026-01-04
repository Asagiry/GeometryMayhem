class_name RangeEnemyAttackScene3
extends Node2D

const LIFETIME_OF_PROJECTILE := 6.0

var projectile_speed: float = 200.0
var direction: Vector2 = Vector2.ZERO
var effects
var magic_find
var max: bool = false

@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var collision_shape: CollisionShape2D = %HitBoxComponent/CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var free_timer: Timer = $QueueFreeTimer

func _ready():
	sprite.play("idle")   
	free_timer.start(LIFETIME_OF_PROJECTILE)
	_update_hitbox(sprite.frame)


func _physics_process(delta):
	position += direction * projectile_speed * delta
	_update_hitbox(sprite.frame)


func _update_hitbox(frame: int) -> void:
	if not max:
		match frame:
			0:
				collision_shape.scale = Vector2(0.5,0.5)
			1:
				collision_shape.scale = Vector2(0.8,0.8)
			2:
				collision_shape.scale = Vector2(1,1)
				max = true
				sprite.stop() 
				sprite.frame = 2 


func _on_hit_box_component_area_entered(area: Area2D):
	if area is HurtBox:
		if area.has_method("deal_damage"):
			area.deal_damage(hit_box_component.damage_data)
		if area.has_method("apply_effect"):
			area.apply_effect(effects, magic_find, hit_box_component.damage_data)
	queue_free()


func set_direction(p_direction: Vector2):
	direction = p_direction.normalized()


func set_projectile_speed(s):
	projectile_speed = s


func set_enemy(enemy: EnemyController):
	effects = enemy.effects
	magic_find = enemy.stats.magic_find


func _on_queue_free_timer_timeout():
	queue_free()
