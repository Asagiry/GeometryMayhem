class_name MeleeEnemyAttackScene1

extends Node2D

var enemy
var direction: float = 1.0

@onready var hit_box_component = %HitBoxComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	randomize()


func _on_hit_box_component_area_entered(area: Area2D) -> void:
	if area is not HurtBox:
		return
	if area.has_method("deal_damage"):
		area.deal_damage(hit_box_component.damage_data)
	if area.has_method("apply_effect"):
		area.apply_effect(enemy.effects)


func start_swing():
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "rotation", deg_to_rad(200) * -direction, 1.0) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_OUT)

	#tween.finished.connect(end_swing)


func end_swing():
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "rotation", 0.0, 0.3) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN)


func set_enemy(p_enemy):
	enemy = p_enemy


func set_attack_range(attack_range):
	direction = (randi() & 1) * 2 - 1
	$AnimatedSprite2D.offset.y = direction * attack_range
	$AnimatedSprite2D/HitBoxComponent/CollisionShape2D.position.y = direction * attack_range



func set_speed_scale(p_speed_scale):
	$AnimatedSprite2D.speed_scale = p_speed_scale
