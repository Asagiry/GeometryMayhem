extends CanvasLayer


@onready var level_lable: Label = %LevelLable
@onready var currency_label: Label = %CurrencyLabel


func _ready():
	Global.meta_progression.meta_updated.connect(_on_update_ui)
	_on_update_ui(Global.meta_progression.player_data)

func _on_update_ui(player_data: PlayerData):
	currency_label.text = "gold: " + str(player_data.currency)
	level_lable.text = "level: " + str(player_data.level)
