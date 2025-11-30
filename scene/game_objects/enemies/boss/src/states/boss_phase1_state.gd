class_name BossPhase1State
extends BossState
#TODO Функционал для последовательных атак
#TODO Функционал для запуска конкретной атаки параллельно
#TODO Функционал для запуска параллельно атак.
static var state_name = "BossPhase1State"

const STAGE_INDEX: int = 0

func enter() -> void:
	_connect_or_disconnect_signals(true)
	_disable_boss_collision()
	_setup_timer()
	attack_controller.prepare_stage(STAGE_INDEX)


func _execute_random_attack():
	if attack_controller.current_stage_attacks.is_empty():
		push_warning("No attacks available in Phase1State!")
		return
	attack_controller.activate_attack(
		attack_controller.current_stage_attacks.pick_random()
	)


func _disable_boss_collision():
	boss.boss_hurt_box.set_deferred("monitoring", false)
	boss.boss_hurt_box.set_deferred("monitorable", false)


func _connect_or_disconnect_signals(connect_status: bool):
	if connect_status:
		boss.tentacle_controller.tentacle_died.connect(_on_phase_changed)
		attack_controller.stage_ready.connect(_on_stage_ready)
		boss.cooldown_between_attacks.timeout.connect(
			_on_cooldown_between_attacks_timer_timeout
		)
		attack_controller.attack_finished.connect(_on_attack_finished)
	else:
		boss.tentacle_controller.tentacle_died.disconnect(_on_phase_changed)
		attack_controller.stage_ready.disconnect(_on_stage_ready)
		boss.cooldown_between_attacks.timeout.disconnect(
			_on_cooldown_between_attacks_timer_timeout
		)
		attack_controller.attack_finished.disconnect(_on_attack_finished)


func _setup_timer():
	boss.cooldown_between_attacks.wait_time = \
	attack_controller.get_stage_cooldown(STAGE_INDEX)


func _on_stage_ready():
	await boss.get_tree().create_timer(0.5).timeout
	_execute_random_attack()


func _on_cooldown_between_attacks_timer_timeout():
	_execute_random_attack()


func _on_phase_changed():
	state_machine.transition(BossPhase2State.state_name)


func _on_attack_finished():
	boss.cooldown_between_attacks.start()


func exit() -> void:
	_connect_or_disconnect_signals(false)


func get_state_name() -> String:
	return state_name
