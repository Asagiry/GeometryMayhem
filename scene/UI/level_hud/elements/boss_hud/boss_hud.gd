class_name BossInfoUI

extends MarginContainer

var hp_data: Dictionary = {}

@onready var game_timer: Timer = %GameTimer
@onready var timer_label: Label = %TimerLabel

@onready var boss_hp_container: VBoxContainer = %BossHpContainer
@onready var body_hp: Label = %BodyHP
@onready var t_1hp: Label = %T1HP
@onready var t_2hp: Label = %T2HP
@onready var t_3hp: Label = %T3HP
@onready var t_4hp: Label = %T4HP

func _ready() -> void:
	Global.player_pulled.connect(_on_player_pulled)
	game_timer.start()


func _process(_delta: float) -> void:
	if timer_label:
		timer_label.text = format_timer(game_timer.time_left)


func format_timer(seconds: float):
	var minutes = int(floor(seconds / 60))
	var remaining_seconds = int(floor(seconds - (minutes * 60)))
	return str(minutes) + ":" + "%02d" % (remaining_seconds)


func _on_game_timer_timeout() -> void:
	Global.game_timer_timeout.emit()


func _on_player_pulled():
	timer_label.queue_free()
	game_timer.queue_free()
	boss_hp_container.visible = true
	var boss = get_tree().get_first_node_in_group("boss") as BossController

	#hp_data["T1HurtBox"] = {
		#"current_health" = boss.stats.tentacle_max_hp,
		#"max_health" = boss.stats.tentacle_max_hp,
		#"label": t_1hp
	#}
	#hp_data["T2HurtBox"] = {
		#"current_health" = boss.stats.tentacle_max_hp,
		#"max_health" = boss.stats.tentacle_max_hp,
		#"label" = t_2hp
	#}
	#hp_data["T3HurtBox"] = {
		#"current_health" = boss.stats.tentacle_max_hp,
		#"max_health" = boss.stats.tentacle_max_hp,
		#"label" = t_3hp
	#}
	#hp_data["T4HurtBox"] = {
		#"current_health" = boss.stats.tentacle_max_hp,
		#"max_health" = boss.stats.tentacle_max_hp,
		#"label" = t_4hp
	#}
	#hp_data["BodyHurtBox"] = {
		#"current_health" = boss.stats.body_max_hp,
		#"max_health" = boss.stats.body_max_hp,
		#"label" = body_hp
	#}
	#for data in hp_data.values():
		#data["label"].text = "hp = " + str(data["current_health"]) + "/" + str(data["max_health"])
#
	#boss.health_component.health_changed.connect(_on_health_decreased)

func _on_health_decreased(current_health: float, p_name: String):
	if current_health<=0:
		hp_data[p_name]["label"].queue_free()
		hp_data.erase(p_name)
		return
	var data = hp_data[p_name]
	data["current_health"] = current_health
	data["label"].text = "hp = " + str(data["current_health"]) + "/" + str(data["max_health"])
