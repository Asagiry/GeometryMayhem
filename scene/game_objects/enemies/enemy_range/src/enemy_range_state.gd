class_name EnemyRangeState

extends State

var enemy: EnemyRangeController
var animated_sprite_2d: AnimatedSprite2D
var enemy_state_machine: StateMachine


func _init(enemy_controller: EnemyRangeController) -> void:
	enemy = enemy_controller
	animated_sprite_2d = enemy.animated_sprite_2d
	enemy_state_machine = enemy.enemy_state_machine
