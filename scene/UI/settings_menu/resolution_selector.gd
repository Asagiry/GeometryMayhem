extends Selector

signal resolution_mode_changed()

func _update_display():
	super._update_display()
	emit_signal("resolution_mode_changed")
