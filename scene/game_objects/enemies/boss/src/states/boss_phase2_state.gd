class_name BossPhase2State
extends BossState

const STAGE_INDEX: int = 1

static var state_name = "BossPhase2State"

func enter() -> void:
	_connect_or_disconnect_signals(true)
	_setup_timer()
	await boss.get_tree().create_timer(0.5).timeout
	attack_controller.prepare_stage(STAGE_INDEX, [3])


func _setup_timer():
	attack_controller.cooldown_between_attacks.wait_time = \
	attack_controller.get_stage_cooldown(STAGE_INDEX)


func _on_stage_ready():
	_sequential_execute_random_attack()
	_parallel_execute_attack(attack_controller.current_stage_attacks[3])
	_parallel_execute_attack(attack_controller.current_stage_attacks[2])
	_parallel_execute_attack(attack_controller.current_stage_attacks[1])


func _on_sequential_attack_finished():
	_sequential_execute_random_attack()


func _on_phase_changed():
	state_machine.transition(BossPhase3State.state_name)


func exit() -> void:
	_connect_or_disconnect_signals(false)
	stop_all_parallel_attacks()


func get_state_name() -> String:
	return state_name
