extends Selector

signal resolution_mode_changed()

func _ready():
	get_resolution_mode()
	super._ready()


func get_resolution_mode():
	if owner != null:
		selected_index = owner.get_resolution_mode()


func _on_left_arrow_pressed():
	super._on_left_arrow_pressed()
	emit_signal("resolution_mode_changed")


func _on_right_arrow_pressed():
	super._on_right_arrow_pressed()
	emit_signal("resolution_mode_changed")
