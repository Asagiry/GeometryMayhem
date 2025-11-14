class_name EnemyAttackState

extends EnemyState

static var state_name = "EnemyAttackState"

var on_cooldown: bool = false

func _init(enemy_controller: EnemyController) -> void:
	super(enemy_controller)
	attack_controller.attack_cd_timeout.connect(_reset_cd)


func enter() -> void:
	attack_controller.attack_started.connect(_on_attack_started)
	attack_controller.attack_cd_timeout.connect(_on_attack_cd_timeout)

	if not on_cooldown:
		on_cooldown = true
		attack_controller.activate_attack()


func _reset_cd():
	on_cooldown = false


func _on_attack_started():
	animated_sprite_2d.play("attack")


func _on_attack_cd_timeout():
	on_cooldown = true
	attack_controller.activate_attack()


func exit():
	attack_controller.attack_started.disconnect(_on_attack_started)
	attack_controller.attack_cd_timeout.disconnect(_on_attack_cd_timeout)


func get_state_name() -> String:
	return state_name
