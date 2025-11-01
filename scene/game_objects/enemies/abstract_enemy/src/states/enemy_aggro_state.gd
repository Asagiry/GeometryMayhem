class_name EnemyAggroState
extends EnemyState

static var state_name = "EnemyAggroState"

var player_in_attack_zone: bool = false
var player_in_aggro_zone: bool = true

func _init(enemy_controller: EnemyController) -> void:
	super(enemy_controller)
	enemy.attack_zone.body_entered.connect(_on_player_entered_attack)
	enemy.attack_zone.body_exited.connect(_on_player_exited_attack)
	enemy.aggro_zone.body_exited.connect(_on_player_exited_aggro)

func enter() -> void:
	player_in_aggro_zone = true
	animated_sprite_2d.play("aggro")

func process(_delta: float) -> void:
	enemy.movement_component.chase_player()

	var attack_state = state_machine.states["EnemyAttackState"]
	if player_in_attack_zone and not attack_state.on_cooldown:
		state_machine.transition(EnemyAttackState.state_name)

func _on_player_entered_attack(body: CharacterBody2D):
	if body is PlayerController:
		player_in_attack_zone = true

func _on_player_exited_attack(body: CharacterBody2D):
	if body is PlayerController:
		player_in_attack_zone = false

func _on_player_exited_aggro(body: CharacterBody2D):
	if body is PlayerController:
		player_in_aggro_zone = false
		state_machine.transition(EnemyBackState.state_name)

func _on_stun_applied(duration: float):
	super(duration)
	state_machine.transition(EnemyStunState.state_name)

func get_state_name() -> String:
	return state_name
