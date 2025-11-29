class_name BossPhase1State
extends BossState

static var state_name = "BossPhase1State"

var current_attacks: Array[Node] = []
var time_since_last_attack: float = 0.0
var attack_cooldown: float = 0.0

# В BossPhase1State:
func enter() -> void:
	print("BossPhase1State: Enter")
	boss.tentacle_controller.tentacle_died.connect(_on_phase_changed)
	boss.boss_hurt_box.set_deferred("monitoring", false)
	boss.boss_hurt_box.set_deferred("monitorable", false)
	await attack_controller.wait_load()
	# Получаем атаки напрямую
	print("Preparing stage...")
	current_attacks = attack_controller.prepare_stage(0)
	print("Stage ready! Current attacks count: ", current_attacks.size())
	
	attack_cooldown = attack_controller.get_stage_cooldown(0)
	print("Attack cooldown: ", attack_cooldown)
	
	_execute_random_attack()

func process(delta: float):
	time_since_last_attack += delta
	if time_since_last_attack >= attack_cooldown:
		print("Time to attack! Cooldown reached")
		_execute_random_attack()
		time_since_last_attack = 0.0

func _execute_random_attack():
	print("Executing random attack")
	if current_attacks.is_empty():
		print("No attacks available!")
		return

	var random_attack = current_attacks[randi() % current_attacks.size()]
	print("Selected attack: ", random_attack.name)
	
	# Запускаем атаку
	attack_controller.activate_attack(random_attack)

func _on_phase_changed():
	state_machine.transition(BossPhase2State.state_name)

func exit() -> void:
	boss.tentacle_controller.tentacle_died.disconnect(_on_phase_changed)

func get_state_name() -> String:
	return state_name
