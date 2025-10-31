class_name EnemyAttackState

extends EnemyState

signal attack_started
signal attack_finished

static var state_name = "EnemyAttackState"

var on_cooldown: bool = false

func _init(enemy_controller: EnemyController) -> void:
	super(enemy_controller)
	attack_controller.attack_started.connect(_on_attack_started)
	attack_controller.attack_finished.connect(_on_attack_finished)
	attack_controller.attack_cd_timeout.connect(_on_attack_cd_timeout)


func enter() -> void:
	on_cooldown = true

	attack_controller.activate_attack()

	attack_started.emit()


func _on_attack_started():
	animated_sprite_2d.play("attack")
	pass


func _on_attack_finished():
	if enemy.is_stunned:
		state_machine.transition(EnemyStunState.state_name)
		return
	state_machine.transition(EnemyAggroState.state_name)


func _on_attack_cd_timeout():
	print("COOLDOWN")
	on_cooldown = false


func get_state_name() -> String:
	return state_name
