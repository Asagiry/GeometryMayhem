class_name EnemyIdleState
extends EnemyState

static var state_name = "EnemyIdleState"

var patrol_timer: Timer
var patrol_duration: float = 2.0

func enter() -> void:
	animated_sprite_2d.play("idle")
	enemy.movement_component.set_new_patrol_target(enemy.spawn_position)
	patrol_timer.start(patrol_duration)


func exit() -> void:
	if patrol_timer:
		patrol_timer.stop()


func process(_delta: float) -> void:
	enemy.movement_component.patrol()

func _setup_patrol_timer() -> void:
	patrol_timer = Timer.new()
	patrol_timer.one_shot = false
	patrol_timer.timeout.connect(_on_patrol_timeout)
	enemy.add_child(patrol_timer)


func _on_patrol_timeout() -> void:
	enemy.movement_component.set_new_patrol_target(enemy.spawn_position)


func get_state_name() -> String:
	return state_name
