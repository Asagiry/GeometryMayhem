class_name EnemyAttackState
extends EnemyState

static var state_name = "EnemyAttackState"

var on_cooldown: bool = false

func _init(enemy_controller: EnemyController) -> void:
	super(enemy_controller)
	attack_controller.attack_cd_timeout.connect(_reset_cd)


func enter() -> void:
	attack_controller.attack_started.connect(_on_attack_started)
	attack_controller.attack_finished.connect(_on_attack_finished)
	attack_controller.attack_cd_timeout.connect(_on_attack_cd_timeout)
	if not on_cooldown:
		_perform_attack()
	else:
		animated_sprite_2d.play("aggro")


func physics_process(_delta: float) -> void:
	enemy.movement_component.handle_knockback_only()


func _perform_attack():
	on_cooldown = true
	state_machine.busy = true
	attack_controller.activate_attack()


func _reset_cd():
	on_cooldown = false


func _on_attack_started():
	animated_sprite_2d.play("attack")


func _on_attack_finished():
	state_machine.busy = false
	state_machine._on_update_enemy_state()


func _on_attack_cd_timeout():
	_perform_attack()


func exit():
	state_machine.busy = false
	attack_controller.attack_started.disconnect(_on_attack_started)
	if attack_controller.attack_cd_timeout.is_connected(_on_attack_cd_timeout):
		attack_controller.attack_cd_timeout.disconnect(_on_attack_cd_timeout)
	if attack_controller.attack_finished.is_connected(_on_attack_finished):
		attack_controller.attack_finished.disconnect(_on_attack_finished)


func get_state_name() -> String:
	return state_name
