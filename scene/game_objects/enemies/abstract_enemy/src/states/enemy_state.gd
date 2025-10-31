class_name EnemyState

extends State

var enemy: EnemyController
var animated_sprite_2d: AnimatedSprite2D
var state_machine: StateMachine
var effect_receiver : EffectReceiver
var attack_controller: EnemyAttackController

func _init(enemy_controller: EnemyController) -> void:
	enemy = enemy_controller
	animated_sprite_2d = enemy.animated_sprite_2d
	state_machine = enemy.state_machine
	effect_receiver = enemy.effect_receiver
	attack_controller = enemy.attack_controller
	effect_receiver.stun_applied.connect(_on_stun_applied)


func _on_stun_applied(duration: float):
	state_machine.states["PlayerStunState"].set_duration(duration)
