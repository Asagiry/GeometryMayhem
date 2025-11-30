class_name FalseBaseMutationAttackScene
extends Node2D

signal attack_finished

const PLAYER_PREDICTION_MOVEMENT: float = 0.5
const START_COLOR: Color = Color(0.8, 0.2, 0.8, 0.6)
const END_COLOR: Color = Color(1, 0, 0, 0.8)

var initial_radius: float = 15.0
var final_radius: float = 50.0
var expansion_time: float = 0.8
var damage_duration: float = 1.0

var player: PlayerController
var effects: Array[Effect]
var magic_find: float

var current_radius: float = 0.0
var current_color: Color = START_COLOR

@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D


func _ready():
	player = get_tree().get_first_node_in_group("player")
	setup_attack()
	start_attack_sequence()


func calculate_position_ahead_of_player():
	if player and is_instance_valid(player):
		var player_velocity = player.velocity
		var player_direction = player_velocity.normalized()
		var distance_ahead = player_velocity.length() * PLAYER_PREDICTION_MOVEMENT
		return player.global_position + player_direction * distance_ahead
	print("Player not found, using default position")
	return Vector2(100, 100)

func setup_attack():
	current_radius = initial_radius
	current_color = START_COLOR
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = current_radius
	collision_shape_2d.shape = circle_shape
	hit_box_component.monitoring = false
	hit_box_component.monitorable = false
	queue_redraw()


func _draw():
	draw_circle(Vector2.ZERO, current_radius, current_color)


func start_attack_sequence():
	await expand_puddle()
	await detonate_puddle()
	finish_attack()


func expand_puddle():
	var expand_tween = create_tween()
	expand_tween.tween_method(_update_radius, initial_radius, final_radius, expansion_time)
	await expand_tween.finished


func _update_radius(current_radius_value: float):
	current_radius = current_radius_value
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = current_radius
	collision_shape_2d.shape = circle_shape
	queue_redraw()


func detonate_puddle():
	hit_box_component.monitoring = true
	hit_box_component.monitorable = true
	var detonate_tween = create_tween()
	detonate_tween.tween_method(_update_detonation_color, 0.0, 1.0, 0.2)
	await detonate_tween.finished
	await get_tree().create_timer(damage_duration).timeout
	hit_box_component.monitoring = false
	hit_box_component.monitorable = false


func _update_detonation_color(progress: float):
	current_color = START_COLOR.lerp(END_COLOR, progress)
	queue_redraw()


func finish_attack():
	var disappear_tween = create_tween()
	disappear_tween.tween_method(_fade_out, 0.8, 0.0, 0.5)
	await disappear_tween.finished
	_on_attack_completed()


func _fade_out(alpha: float):
	current_color.a = alpha
	queue_redraw()


func _on_attack_completed():
	attack_finished.emit()
	queue_free()


func set_enemy(p_enemy: BossController):
	effects = p_enemy.effects
	magic_find = p_enemy.stats.magic_find


func set_parameters(
	p_initial_radius,
	p_final_radius,
	p_expansion_time,
	p_damage_duration,
):
	initial_radius = p_initial_radius
	final_radius = p_final_radius
	expansion_time = p_expansion_time
	damage_duration = p_damage_duration


func set_damage(damage_data: DamageData):
	hit_box_component.damage_data = damage_data


func _on_hit_box_component_area_entered(area: Area2D):
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
