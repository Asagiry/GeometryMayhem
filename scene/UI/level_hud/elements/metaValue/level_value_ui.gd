class_name LevelValueUI

extends MarginContainer

@onready var real_label: Label = %RealLabel

func set_value(p_value: int):
	real_label.text = str(p_value)
