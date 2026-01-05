extends PanelContainer

@onready var title_label: Label = %Title
@onready var desc_label: Label = %Description
@onready var icon: TextureRect = %Icon

func set_data(title: String, desc: String, unlocked: bool):
	title_label.text = title
	desc_label.text = desc
	if unlocked:
		modulate = Color.WHITE
	else:
		modulate = Color(0.6, 0.6, 0.6)
