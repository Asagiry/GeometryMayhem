class_name BossState

extends State

var boss: BossController
var animated_sprite_2d: AnimatedSprite2D
var state_machine: StateMachine
var attack_controller: BossAttackController
var active_parallel_attacks: Dictionary = {}

func _init(boss_controller: BossController) -> void:
	boss = boss_controller
	state_machine = boss_controller.state_machine
	animated_sprite_2d = boss_controller.animated_sprite_2d
	attack_controller = boss_controller.attack_controller


func _on_phase_changed():
	pass


func _sequential_execute_random_attack():
	if attack_controller.current_stage_attacks.is_empty():
		push_warning("No attacks available in Phase1State!")
		return
	attack_controller.activate_sequential_attack(
		attack_controller.current_stage_sequential_attacks.pick_random()
	)


func _parallel_execute_attack(attack_instance: Node):
	if attack_controller.current_stage_attacks.is_empty():
		push_warning("No attacks available in Phase1State!")
		return
	if not active_parallel_attacks.has(attack_instance):
		active_parallel_attacks[attack_instance] = true
		attack_controller.activate_parallel_attack(attack_instance)


func _parallel_stop_attack(attack_instance: Node):
	if attack_controller.current_stage_attacks.is_empty():
		push_warning("No attacks available in Phase1State!")
		return
	if active_parallel_attacks.has(attack_instance):
		active_parallel_attacks.erase(attack_instance)
		attack_controller.stop_parallel_attack(attack_instance)


func stop_all_parallel_attacks():
	for attack_instance in active_parallel_attacks:
		if is_instance_valid(attack_instance):
			attack_controller.stop_parallel_attack(attack_instance)
	active_parallel_attacks.clear()


func _connect_or_disconnect_signals(connect_status: bool):
	if connect_status:
		boss.tentacle_controller.tentacle_died.connect(_on_phase_changed)
		attack_controller.stage_ready.connect(_on_stage_ready)
		attack_controller.sequential_attack_finished.connect(
			_on_sequential_attack_finished
		)
	else:
		boss.tentacle_controller.tentacle_died.disconnect(_on_phase_changed)
		attack_controller.stage_ready.disconnect(_on_stage_ready)
		attack_controller.sequential_attack_finished.disconnect(
			_on_sequential_attack_finished
		)


func _on_stage_ready():
	pass


func _on_sequential_attack_finished():
	pass
