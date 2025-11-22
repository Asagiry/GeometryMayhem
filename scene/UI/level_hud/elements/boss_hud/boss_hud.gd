class_name BossInfoUI

extends MarginContainer

var is_timer_finished: bool = false
var elapsed_after_finish: float = 0.0


@onready var game_timer: Timer = %GameTimer
@onready var timer_label: Label = %TimerLabel
@onready var boss_hp_container: VBoxContainer = %BossHpContainer

@onready var body_hp_bar: BossHPBarUI = %BodyHPBar
@onready var tentacle_hp_bar_1: BossHPBarUI = %TentacleHPBar1
@onready var tentacle_hp_bar_2: BossHPBarUI = %TentacleHPBar2
@onready var tentacle_hp_bar_3: BossHPBarUI = %TentacleHPBar3
@onready var tentacle_hp_bar_4: BossHPBarUI = %TentacleHPBar4

func _ready() -> void:
	Global.player_pulled.connect(_on_player_pulled)
	game_timer.start()


func _process(_delta: float) -> void:
	if not timer_label:
		return

	if not is_timer_finished:
		timer_label.text = format_timer(game_timer.time_left)
	else:
		elapsed_after_finish += _delta
		var negative_time = -elapsed_after_finish
		timer_label.text = format_timer(negative_time)


func format_timer(seconds: float) -> String:
	var is_negative = seconds < 0
	seconds = abs(seconds)

	var minutes = int(seconds / 60)
	var secs = int(fmod(seconds, 60))

	var sign = "-" if is_negative else ""
	return sign + str(minutes) + ":" + "%02d" % secs


func _on_game_timer_timeout() -> void:
	is_timer_finished = true
	Global.game_timer_timeout.emit()


func _on_player_pulled():
	timer_label.queue_free()
	game_timer.queue_free()
	boss_hp_container.visible = true
	var boss = get_tree().get_first_node_in_group("boss") as BossController

	boss.health_component.health_decreased.connect(_on_body_hp_changed)
	boss.health_component.health_increased.connect(_on_body_hp_changed)

	for i in range(4):
		boss.tentacle_controller.tentacles[i].\
		health_component.\
		health_increased.\
		connect(_on_tentacle_hp_changed.bind(i))
		boss.tentacle_controller.tentacles[i].\
		health_component.\
		health_decreased.\
		connect(_on_tentacle_hp_changed.bind(i))


func _on_body_hp_changed(current_health: float,max_health: float):
	body_hp_bar.max_value = max_health
	body_hp_bar.value = current_health


func _on_tentacle_hp_changed(current_health: float, max_health: float, id: int):
	match id:
		0:
			tentacle_hp_bar_1.max_value = max_health
			tentacle_hp_bar_1.value = current_health
		1:
			tentacle_hp_bar_2.max_value = max_health
			tentacle_hp_bar_2.value = current_health
		2:
			tentacle_hp_bar_3.max_value = max_health
			tentacle_hp_bar_3.value = current_health
		3:
			tentacle_hp_bar_4.max_value = max_health
			tentacle_hp_bar_4.value = current_health
