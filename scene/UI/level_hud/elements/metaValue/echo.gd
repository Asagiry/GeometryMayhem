class_name EchoUI

extends MarginContainer

const MAX_DIGITS = 8

@onready var ghost_label: Label = %GhostLabel
@onready var real_label: Label = %RealLabel

func set_value(p_value: int):
	var count: int = 0
	for i in range(MAX_DIGITS):
		var digit = p_value / int(pow(10,i))
		if digit!=0:
			count+=1
	print(count)
	real_label.text = str(p_value)
	ghost_label.text = "0".repeat(count)
