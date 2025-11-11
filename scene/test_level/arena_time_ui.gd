class_name ArenaTimeUI

extends Control

@onready var game_timer: Timer = %GameTimer
@onready var time_label: Label = %Label

func _ready() -> void:
	game_timer.start()


func _process(_delta: float) -> void:
	time_label.text = format_timer(game_timer.time_left)


func format_timer(seconds: float):
	var minutes = int(floor(seconds / 60))
	var remaining_seconds = int(floor(seconds - (minutes * 60)))
	return str(minutes) + ":" + "%02d" % (remaining_seconds)
