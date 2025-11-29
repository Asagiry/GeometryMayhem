class_name BossState

extends State

var boss: BossController
var animated_sprite_2d: AnimatedSprite2D
var state_machine: StateMachine
var attack_controller: BossAttackController

func _init(boss_controller: BossController) -> void:
	boss = boss_controller
	state_machine = boss_controller.state_machine
	animated_sprite_2d = boss_controller.animated_sprite_2d
	attack_controller = boss_controller.attack_controller


func _on_phase_changed():
	pass
