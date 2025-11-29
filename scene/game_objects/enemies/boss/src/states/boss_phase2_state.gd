class_name BossPhase2State

extends BossState

static var state_name = "BossPhase2State"

func enter() -> void:
	boss.tentacle_controller.tentacle_died.connect(_on_phase_changed)


func _on_phase_changed():
	state_machine.transition(BossPhase3State.state_name)


func exit() -> void:
	boss.tentacle_controller.tentacle_died.disconnect(_on_phase_changed)


func get_state_name() -> String:
	return state_name
