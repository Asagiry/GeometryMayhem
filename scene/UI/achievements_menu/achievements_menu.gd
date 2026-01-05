extends CanvasLayer


@onready var list := %AchievementsList

func _on_quit_button_pressed() -> void:
	queue_free()


func _ready():
	print("AchievementsMenu READY")
	_add_achievement("First Blood", "Defeat your first enemy", true)
	_add_achievement("Hunter", "Defeat 50 enemies", false)
	_add_achievement("Getting Started", "Finish your first run", true)
	_add_achievement("Survivor", "Survive 5 minutes", false)

func _add_achievement(title: String, desc: String, unlocked: bool):
	var card = preload("res://scene/UI/achievements_menu/achievement_card.tscn").instantiate()
	list.add_child(card)
	card.set_data(title, desc, unlocked)
	print("Added card:", card.name, " children now:", list.get_child_count())
