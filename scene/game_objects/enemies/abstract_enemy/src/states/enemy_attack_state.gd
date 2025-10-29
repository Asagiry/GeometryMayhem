class_name EnemyAttackState
extends EnemyState

static var state_name = "EnemyAttackState"

var attack_duration: float = 0.8
var attack_timer: Timer
var is_attacking: bool = false

func _init(enemy_controller: EnemyController) -> void:
	super(enemy_controller)
	_setup_attack_timer()

func enter() -> void:
	animated_sprite_2d.play("attack")
	enemy.movement_component.stop()
	is_attacking = true
	attack_timer.start(attack_duration)


func exit() -> void:
	if attack_timer:
		attack_timer.stop()
	is_attacking = false


func process(_delta: float) -> void:
	if not _player_in_hit_box():
		_transition_to_appropriate_state()


func _transition_to_appropriate_state() -> void:
	if _player_in_agro_zone():
		enemy_state_machine.transition(EnemyAgroState.state_name)
	else:
		enemy_state_machine.transition(EnemyBackState.state_name)


func _setup_attack_timer() -> void:
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_finished)
	enemy.add_child(attack_timer)


func _on_attack_finished() -> void:
	is_attacking = false
	if _player_in_hit_box():
		enemy_state_machine.transition(EnemyAttackState.state_name)
	else:
		_transition_to_appropriate_state()


func _player_in_hit_box() -> bool:
	if enemy.hit_box:
		var overlapping_bodies = enemy.hit_box.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("player"):
				return true
	return false


func _player_in_agro_zone() -> bool:
	if enemy.agro_zone:
		var overlapping_bodies = enemy.agro_zone.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("player"):
				return true
	return false


func get_state_name() -> String:
	return state_name
