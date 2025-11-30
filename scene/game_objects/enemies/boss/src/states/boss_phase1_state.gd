class_name BossPhase1State
## Гайд как делать стадию.
## Индекс стадии STAGE_INDEX = Phase1 - 1 = 0 ИЛИ Phase2 - 1 = 1
## Вызвать 2 функции в enter() _connect_or_disconnect_signals(true), и
## _setup_timer()
## вызвать функцию attack_controller.prepare_stage(STAGE_INDEX)
## в prepare_stage вторым аргмуентом можно подать массив intов.
## Где каждый int = атаке, которую мы хотим исключить.
## Как понять, какой int соотвествует атаке, которую мы хотим исключить?
## Когда в инспекторе выбираются конфиги атак - они идут по порядку.
## Первый конфиг допустим SpiralAttackConfig - у него значит индекс = 0.
## И так далее надеюсь понятно.
## Самое главная функция - _on_stage_ready().
## Здесь можно запускать атаки параллельно с помощью _parallel_execute_attack()
## Аргумент подается вот такой attack_controller.current_stage_attacks[1].
## 1 - индекс атаки, как найти индекс нужной атаки - написано выше.
## Или можно запустить атаки последовательно - _sequential_execute_random_attack()
## Из массива всех атак, которые мы выбрали в инспекторе как конфиги -
## минус исключенные нами атаки будет браться из массива рандомно одна атака.
## И пока не завершиться первая - вторая не начнется. И еще существует кулдаун
## Между этими атаками, переменная для него находится в attack_stage_config.
## Кулдаун для последовательных атак выбирается в инспекторе.

extends BossState

const STAGE_INDEX: int = 0

static var state_name = "BossPhase1State"

func enter() -> void:
	_connect_or_disconnect_signals(true)
	_disable_boss_collision()
	_setup_timer()
	await boss.get_tree().create_timer(0.5).timeout
	attack_controller.prepare_stage(STAGE_INDEX, [1])


func _disable_boss_collision():
	boss.boss_hurt_box.set_deferred("monitoring", false)
	boss.boss_hurt_box.set_deferred("monitorable", false)


func _setup_timer():
	attack_controller.cooldown_between_attacks.wait_time = \
	attack_controller.get_stage_cooldown(STAGE_INDEX)


func _on_stage_ready():
	_sequential_execute_random_attack()
	_parallel_execute_attack(attack_controller.current_stage_attacks[1])


func _on_sequential_attack_finished():
	_sequential_execute_random_attack()


func _on_phase_changed():
	state_machine.transition(BossPhase2State.state_name)


func exit() -> void:
	_connect_or_disconnect_signals(false)
	stop_all_parallel_attacks()


func get_state_name() -> String:
	return state_name
