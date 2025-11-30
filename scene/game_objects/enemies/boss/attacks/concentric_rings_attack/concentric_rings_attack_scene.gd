class_name ConcentricRingsAttackScene
extends Node2D

var center_node: Node2D

var radius: float
var current_angle: float
var angular_speed: float

var effects: Array[Effect]
var magic_find: float

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var hit_box_component: HitBoxComponent = %HitBoxComponent

func _physics_process(delta: float) -> void:
	if not is_instance_valid(center_node):
		queue_free()
		return

	current_angle += angular_speed * delta

	var offset = Vector2(cos(current_angle), sin(current_angle)) * radius
	global_position = center_node.global_position + offset
	var rotation_offset = PI / 2.0 if angular_speed >= 0 else -PI / 2.0
	rotation = current_angle + rotation_offset


func set_parameters(
	p_projectile_size: float,
	p_center_node: Node2D,
	p_radius: float,
	p_start_angle: float,
	p_speed: float,
):
	_set_projectile_size(p_projectile_size)
	center_node = p_center_node
	radius = p_radius
	current_angle = p_start_angle
	angular_speed = p_speed


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
