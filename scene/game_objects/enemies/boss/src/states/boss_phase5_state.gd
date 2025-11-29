class_name BossPhase5State

extends BossState

static var state_name = "BossPhase5State"

func enter() -> void:
	boss.boss_hurt_box.set_deferred("monitoring", true)
	boss.boss_hurt_box.set_deferred("monitorable", true)


func exit() -> void:
	pass


func get_state_name() -> String:
	return state_name
