@tool  # ← ОБЯЗАТЕЛЬНО для отображения в редакторе
class_name MiniMap
extends SubViewportContainer

@onready var sub_viewport: SubViewport = %SubViewport

func _ready():
	stretch = true
	_update_viewport_size()

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		_update_viewport_size()

func _update_viewport_size():
	if sub_viewport:
		sub_viewport.size = size
