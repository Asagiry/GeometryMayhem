class_name SawedOffAttackController
extends BaseBossAttackController

var damage: DamageData = DamageData.new()
var projectile_speed: float
var projectile_size: float
var shots_per_burst: int
var shots_angle: float

var is_parallel_mode: bool = true

@onready var cooldown_timer: Timer = %CooldownTimer

func activate_attack():
	attack_started.emit()
	_create_and_setup_attack()
	attack_finished.emit()


func activate_parallel_attack():
	await activate_attack()
	if is_parallel_mode:
		_start_cooldown()


func _create_and_setup_attack():
	var base_direction = _get_direction_to_player()
	var total_angle_rad = deg_to_rad(shots_angle)
	var angle_step = 0.0
	var start_angle = 0.0

	if shots_per_burst > 1:
		angle_step = total_angle_rad / (shots_per_burst - 1)
		start_angle = -total_angle_rad / 2.0

	for i in range(shots_per_burst):
		var current_angle = start_angle + (angle_step * i)
		var final_direction = base_direction.rotated(current_angle)
		var attack_instance = _create_attack_instance()
		_setup_attack_instance(attack_instance, final_direction)

	return null


func _setup_attack_instance(
	attack_instance: SawedOffAttackScene,
	direction: Vector2
) -> void:
	attack_instance.global_position = owner.global_position
	attack_instance.rotation += direction.angle()
	attack_instance.set_enemy(owner)
	attack_instance.set_damage(damage)

	attack_instance.set_parameters(
		projectile_speed,
		projectile_size,
		direction
	)


func _create_attack_instance():
	var attack_instance = attack_scene.instantiate() as SawedOffAttackScene
	get_tree().get_first_node_in_group("front_layer").add_child(attack_instance)
	return attack_instance


func set_damage(p_damage: DamageData):
	damage = p_damage


func set_projectile_speed(value: float) -> void:
	projectile_speed = value


func set_projectile_size(value: float) -> void:
	projectile_size = value


func set_cooldown_time(value: float) -> void:
	cooldown_timer.wait_time = value


func set_shots_per_burst(value: int) -> void:
	shots_per_burst = max(1, value)


func set_shots_angle(value: float) -> void:
	shots_angle = value


func _start_cooldown():
	cooldown_timer.start()


func _on_cooldown_timer_timeout() -> void:
	if is_parallel_mode:
		activate_parallel_attack()
