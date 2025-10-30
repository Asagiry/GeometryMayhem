class_name EnemyState

extends State

var enemy: EnemyController
var animated_sprite_2d: AnimatedSprite2D
var state_machine: StateMachine


func _init(enemy_controller: EnemyController) -> void:
	enemy = enemy_controller
	animated_sprite_2d = enemy.animated_sprite_2d
	state_machine = enemy.state_machine
	enemy.aggro_zone.body_entered.connect(_on_player_entered_aggro)
	enemy.aggro_zone.body_exited.connect(_on_player_exited_aggro)
	enemy.attack_zone.body_entered.connect(_on_player_entered_attack)
	enemy.attack_zone.body_exited.connect(_on_player_exited_attack)

func _on_player_entered_aggro(_body:CharacterBody2D):
	pass

func _on_player_entered_attack(_body:CharacterBody2D):
	pass

func _on_player_exited_aggro(_body:CharacterBody2D):
	pass

func _on_player_exited_attack(_body:CharacterBody2D):
	pass
