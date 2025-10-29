class_name EnemyRangeIdleState
extends EnemyRangeState

static var state_name = "EnemyRangeIdleState"

var patrol_timer: Timer
var patrol_duration: float = 2.0


func _init(enemy_controller: EnemyRangeController) -> void:
	super(enemy_controller)
	_setup_patrol_timer()


func enter() -> void:
	animated_sprite_2d.play("idle_bug")
	enemy.movement_component.set_new_patrol_target(enemy.spawn_position)
	patrol_timer.start(patrol_duration)


func exit() -> void:
	if patrol_timer:
		patrol_timer.stop()


func process(_delta: float) -> void:
	enemy.movement_component.patrol(enemy)
	if enemy.movement_component.has_reached_patrol_target(enemy):
		enemy.movement_component.set_new_patrol_target(enemy.spawn_position)
	if _player_in_agro_zone():
		enemy_state_machine.transition(EnemyRangeAgroState.state_name)


func _setup_patrol_timer() -> void:
	patrol_timer = Timer.new()
	patrol_timer.one_shot = false
	patrol_timer.timeout.connect(_on_patrol_timeout)
	enemy.add_child(patrol_timer)


func _on_patrol_timeout() -> void:
	enemy.movement_component.set_new_patrol_target(enemy.spawn_position)


func _player_in_agro_zone() -> bool:
	if enemy.agro_zone:
		var overlapping_bodies = enemy.agro_zone.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("player"):
				return true
	return false


func get_state_name() -> String:
	return state_name
