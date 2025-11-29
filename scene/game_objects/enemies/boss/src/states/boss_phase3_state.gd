class_name BossPhase3State

extends BossState

static var state_name = "BossPhase3State"

func enter() -> void:
	boss.tentacle_controller.tentacle_died.connect(_on_phase_changed)


func _on_phase_changed():
	state_machine.transition(BossPhase4State.state_name)


func exit() -> void:
	boss.tentacle_controller.tentacle_died.disconnect(_on_phase_changed)


func get_state_name() -> String:
	return state_name
