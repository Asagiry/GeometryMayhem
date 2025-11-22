class_name MeleeEnemyAttackScene1

extends Node2D

var direction: float = 1.0
var effects: Array[Effect]
var magic_find: float

@onready var hit_box_component = %HitBoxComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D


func _ready() -> void:
	randomize()


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


func start_swing():
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "rotation", deg_to_rad(200) * -direction, 1.0) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_OUT)


func set_enemy(p_enemy):
	effects = p_enemy.effects
	magic_find = p_enemy.stats.magic_find


func set_attack_range(attack_range):
	direction = (randi() & 1) * 2 - 1
	animated_sprite_2d.offset.y = direction * attack_range
	collision_shape_2d.position.y = direction * attack_range



func set_speed_scale(p_speed_scale):
	animated_sprite_2d.speed_scale = p_speed_scale
