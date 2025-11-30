class_name GifGloveAttackController
extends BaseBossAttackController

const BURST_DELAY: float = 0.15

var damage: DamageData = DamageData.new()
var projectile_speed: float
var projectile_size: float
var prediction_accuracy: float
var shots_per_burst: int

var is_parallel_mode: bool = true

@onready var cooldown_timer: Timer = %CooldownTimer

func activate_attack():
	attack_started.emit()
	for i in range(shots_per_burst):
		if not is_parallel_mode and i > 0:
			break
		_create_and_setup_attack()
		if i < shots_per_burst - 1:
			await get_tree().create_timer(BURST_DELAY).timeout
	attack_finished.emit()


func activate_parallel_attack():
	await activate_attack()
	if is_parallel_mode:
		_start_cooldown()


func _create_and_setup_attack():
	var attack_instance = _create_attack_instance()
	_setup_attack_instance(attack_instance, _get_predicted_direction())
	return attack_instance


func _setup_attack_instance(
	attack_instance: GifGloveAttackScene,
	direction_to_player: Vector2
) -> void:
	attack_instance.global_position = owner.global_position
	attack_instance.rotation += direction_to_player.angle()
	attack_instance.set_enemy(owner)
	attack_instance.set_damage(damage)
	attack_instance.set_parameters(
		projectile_speed,
		projectile_size,
		direction_to_player
	)


func _create_attack_instance():
	var attack_instance = attack_scene.instantiate() as GifGloveAttackScene
	get_tree().get_first_node_in_group("front_layer").add_child(attack_instance)
	return attack_instance


func _get_predicted_direction() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return Vector2.RIGHT
	var source_pos = owner.global_position
	var target_pos = player.global_position
	var target_velocity = player.velocity
	var distance = source_pos.distance_to(target_pos)
	var time_to_hit = 0.0
	if projectile_speed > 0:
		time_to_hit = distance / projectile_speed
	var predicted_pos = target_pos + (target_velocity * time_to_hit * prediction_accuracy)
	return (predicted_pos - source_pos).normalized()


func set_damage(p_damage: DamageData):
	damage = p_damage


func set_projectile_speed(value: float) -> void:
	projectile_speed = value


func set_projectile_size(value: float) -> void:
	projectile_size = value


func set_prediction_accuracy(value: float) -> void:
	prediction_accuracy = value


func set_cooldown_time(value: float) -> void:
	cooldown_timer.wait_time = value


func set_shots_per_burst(value: int) -> void:
	shots_per_burst = max(1, value)


func _start_cooldown():
	cooldown_timer.start()


func _on_cooldown_timer_timeout() -> void:
	if is_parallel_mode:
		activate_parallel_attack()
