class_name EnemyBombState

extends State

var enemy: EnemyBombController
var animated_sprite_2d: AnimatedSprite2D
var enemy_state_machine: StateMachine


func _init(enemy_controller: EnemyBombController) -> void:
	enemy = enemy_controller
	animated_sprite_2d = enemy.animated_sprite_2d
	enemy_state_machine = enemy.enemy_state_machine
