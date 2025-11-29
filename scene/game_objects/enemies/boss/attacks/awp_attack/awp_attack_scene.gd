class_name AwpAttackScene
extends Node2D

signal attack_finished

const AIM_COLOR: Color = Color(1, 0, 0, 0.3)
const LINE_WIDTH: float = 10.0
const LINE_LENGTH: float = 2000.0

var aim_duration: float = 2.0
var delay_before_attack: float = 0.5
var number_of_shots: int = 1
var time_between_shots: float = 0.2

var effects: Array[Effect]
var magic_find: float
var player: PlayerController

var target_position: Vector2
var final_attack_direction: Vector2
var is_aiming_phase: bool = true

@onready var line_renderer: Line2D = $Line2D
@onready var hit_box_component: HitBoxComponent = %HitBoxComponent
@onready var collision_shape: CollisionShape2D = $HitBoxComponent/CollisionShape2D

func _ready():
	player = get_tree().get_first_node_in_group("player")
	setup_attack()
	start_attack_sequence()


func _process(delta: float) -> void:
	if player and is_instance_valid(player) and is_aiming_phase:
		target_position = player.global_position
		var attack_direction = global_position.direction_to(target_position)
		var line_end = attack_direction * LINE_LENGTH
		line_renderer.points = [Vector2.ZERO, line_end]
		setup_collision_shape(attack_direction)


func setup_attack():
	line_renderer.width = LINE_WIDTH
	line_renderer.default_color = AIM_COLOR
	hit_box_component.monitoring = false
	hit_box_component.monitorable = false


func setup_collision_shape(direction: Vector2):
	var shape = RectangleShape2D.new()
	shape.size = Vector2(LINE_LENGTH, LINE_WIDTH)
	collision_shape.shape = shape
	collision_shape.rotation = direction.angle()
	collision_shape.position = direction * (LINE_LENGTH / 2)


func start_attack_sequence():
	await get_tree().create_timer(aim_duration).timeout
	is_aiming_phase = false
	final_attack_direction = global_position.direction_to(target_position)
	line_renderer.points = [Vector2.ZERO, final_attack_direction * LINE_LENGTH]

	if delay_before_attack > 0:
		var delay_tween = create_tween()
		delay_tween.tween_property(
			line_renderer,
			"default_color",
			Color(1, 1, 0, 0.6),
			delay_before_attack * 0.5
		)  # Желтый
		delay_tween.tween_property(
			line_renderer,
			"default_color",
			Color(1, 0, 0, 0.8),
			delay_before_attack * 0.5
		)  # Красный
		await get_tree().create_timer(delay_before_attack).timeout

	await start_multiple_shots()


func start_multiple_shots():
	setup_collision_shape(final_attack_direction)

	for shot_number in number_of_shots:
		var shot_tween = create_tween()
		shot_tween.tween_property(line_renderer, "default_color", Color(1, 1, 1, 0.9), 0.05)  # Белая вспышка
		shot_tween.tween_property(line_renderer, "default_color", Color(1, 0, 0, 0.8), 0.05)  # Возврат к красному

		await perform_single_shot()

		if shot_number < number_of_shots - 1:
			await get_tree().create_timer(time_between_shots).timeout

	finish_attack()


func perform_single_shot():
	enable_hitbox()
	await get_tree().create_timer(0.05).timeout
	disable_hitbox()


func enable_hitbox():
	hit_box_component.monitoring = true
	hit_box_component.monitorable = true


func disable_hitbox():
	hit_box_component.monitoring = false
	hit_box_component.monitorable = false


func finish_attack():
	var disappear_tween = create_tween()
	disappear_tween.tween_property(line_renderer, "width", 0.0, 0.2)
	disappear_tween.tween_callback(_on_attack_completed)


func _on_attack_completed():
	attack_finished.emit()
	queue_free()


func set_enemy(p_enemy: BossController):
	effects = p_enemy.effects
	magic_find = p_enemy.stats.magic_find


func set_parameters(
	p_aim_duration: float,
	p_delay_before_attack: float,
	p_number_of_shots: int,
	p_time_between_shots: float = 0.2
):
	aim_duration = p_aim_duration
	delay_before_attack = p_delay_before_attack
	number_of_shots = p_number_of_shots
	time_between_shots = p_time_between_shots


func set_damage(damage: DamageData):
	hit_box_component.damage_data = damage


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
