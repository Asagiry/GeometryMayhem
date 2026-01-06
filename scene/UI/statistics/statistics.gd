extends CanvasLayer

@onready var runs_label: Label = $"Control/VBoxContainer/VBoxContainer/MarginContainer/GridContainer/PanelContainer/MarginContainer/VBoxContainer/Runs"
@onready var kills_label: Label = $"Control/VBoxContainer/VBoxContainer/MarginContainer/GridContainer/PanelContainer2/MarginContainer/VBoxContainer/Kills"
@onready var best_score_label: Label = $"Control/VBoxContainer/VBoxContainer/MarginContainer/GridContainer/PanelContainer3/MarginContainer/VBoxContainer/BestScore"
@onready var bosses_killed_label: Label = $"Control/VBoxContainer/VBoxContainer/MarginContainer/GridContainer/PanelContainer4/MarginContainer/VBoxContainer/BossesKilled"


func _ready() -> void:
	_refresh_stats()

func _refresh_stats() -> void:
	var total_kills := Global.base_total_kills + Global.session_total_kills_add
	var runs := Global.base_games_played + Global.session_games_played_add
	var best_score = max(Global.base_max_kills_in_game, Global.session_best_kills_in_game)
	var bosses_killed := Global.base_boss_killed + Global.session_boss_killed_add

	runs_label.text = str(runs)
	kills_label.text = str(total_kills)
	best_score_label.text = str(best_score)
	bosses_killed_label.text = str(bosses_killed)

func _on_quit_button_pressed() -> void:
	queue_free()
