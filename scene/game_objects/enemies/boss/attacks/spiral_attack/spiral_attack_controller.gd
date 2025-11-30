class_name SpiralAttackController
extends BaseBossAttackController

const EXPANSION_DISTANCE: float = 150.0
const EXPAND_DURATION: float = 1.0
const RETRACT_DURATION: float = 1.0
const RESET_DURATION: float = 0.5

var duration: float
var rotation_speed: float

var is_parallel_mode: bool = true
var is_attacking: bool = false

var current_radius_offset: float = 0.0
var current_rotation_offset: float = 0.0
var boss_initial_rotation: float = 0.0

var tentacles_data: Dictionary = {}

@onready var cooldown_timer: Timer = %CooldownTimer

func _ready() -> void:
	set_physics_process(false)


func activate_attack():
	if is_attacking:
		return
	is_attacking = true
	attack_started.emit()
	await _perform_attack_sequence()
	is_attacking = false
	attack_finished.emit()


func activate_parallel_attack():
	await activate_attack()
	if is_parallel_mode:
		_start_cooldown()


func _perform_attack_sequence():
	_capture_tentacles_initial_state()
	set_physics_process(true)
	var tween = create_tween()
	tween.tween_property(self, "current_radius_offset", EXPANSION_DISTANCE, EXPAND_DURATION)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var spin_time = max(0.0, duration - EXPAND_DURATION - RETRACT_DURATION)
	if spin_time > 0:
		await get_tree().create_timer(EXPAND_DURATION + spin_time).timeout
	else:
		await get_tree().create_timer(EXPAND_DURATION).timeout
	var retract_tween = create_tween()
	retract_tween.tween_property(self, "current_radius_offset", 0.0, RETRACT_DURATION)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await retract_tween.finished
	set_physics_process(false)
	await _reset_tentacles_position()


func _physics_process(delta: float) -> void:
	if not owner:
		return
	var speed_rad = deg_to_rad(rotation_speed)
	current_rotation_offset += speed_rad * delta

	var boss_rotation_diff = owner.rotation - boss_initial_rotation
	var tentacle_controller = owner.tentacle_controller
	if not tentacle_controller: return

	for tentacle in tentacle_controller.tentacles:
		if not is_instance_valid(tentacle): continue
		if not tentacles_data.has(tentacle): continue

		var data = tentacles_data[tentacle]
		var base_radius = data["base_radius"]
		var base_angle = data["base_angle"]

		var final_radius = base_radius + current_radius_offset
		var final_angle = base_angle + current_rotation_offset - boss_rotation_diff

		var new_pos = Vector2(cos(final_angle), sin(final_angle)) * final_radius
		tentacle.position = new_pos
		tentacle.rotation = final_angle + PI / 2.0


func _capture_tentacles_initial_state():
	tentacles_data.clear()
	var tentacle_controller = owner.tentacle_controller
	if not tentacle_controller: return

	current_rotation_offset = 0.0
	current_radius_offset = 0.0
	boss_initial_rotation = owner.rotation # Запоминаем поворот босса

	for tentacle in tentacle_controller.tentacles:
		if is_instance_valid(tentacle):
			tentacles_data[tentacle] = {
				"base_radius": tentacle.position.length(),
				"base_angle": tentacle.position.angle(),
				"original_rotation": tentacle.rotation
			}


func _reset_tentacles_position():
	var tween = create_tween().set_parallel(true)
	var has_valid_tentacles = false
	for tentacle in tentacles_data:
		if is_instance_valid(tentacle):
			has_valid_tentacles = true
			var data = tentacles_data[tentacle]
			var base_angle = data["base_angle"]
			var base_radius = data["base_radius"] # Используем базовый радиус
			var orig_rot = data["original_rotation"]

			var reset_pos = Vector2(cos(base_angle), sin(base_angle)) * base_radius

			tween.tween_property(tentacle, "position", reset_pos, RESET_DURATION)\
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			var diff = angle_difference(tentacle.rotation, orig_rot)
			var target_rot = tentacle.rotation + diff
			tween.tween_property(tentacle, "rotation", target_rot, RESET_DURATION)\
				.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	if has_valid_tentacles:
		await tween.finished


func set_duration(value: float) -> void:
	duration = value


func set_cooldown_time(value: float) -> void:
	cooldown_timer.wait_time = value


func set_rotation_speed(value: float) -> void:
	rotation_speed = value


func _start_cooldown():
	cooldown_timer.start()


func _on_cooldown_timer_timeout() -> void:
	if is_parallel_mode:
		activate_parallel_attack()
