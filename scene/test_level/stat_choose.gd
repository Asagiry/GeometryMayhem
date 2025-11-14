extends MenuButton

@export var stat_data: StatModifierData

var vbox: VBoxContainer

var field_names = [
		"speed_multiplier",
		"attack_multiplier",
		"armor_multiplier",
		"forward_receiving_damage_multiplier",
		"attack_cd_multiplier",
		"attack_duration_multiplier",
		"invulnerable",
		"percent_of_max_health",
		"attack_range_multiplier"
	]

func _ready() -> void:
	if stat_data == null:
		stat_data = StatModifierData.new()

	# Создаем Window вместо PopupPanel
	var window = Window.new()
	window.name = "StatEditorWindow"
	window.borderless = true
	window.size = Vector2(300, 150)
	window.visible = false
	window.unresizable = true
	window.wrap_controls = true
	window.unresizable = true
	window.initial_position = Window.WINDOW_INITIAL_POSITION_ABSOLUTE

	add_child(window)

	vbox = VBoxContainer.new()
	window.add_child(vbox)


	for field_name in field_names:
		var hbox = HBoxContainer.new()
		vbox.add_child(hbox)

		var label = Label.new()
		label.text = field_name
		label.custom_minimum_size.x = 180
		hbox.add_child(label)
		if field_name == "invulnerable":
			var check_box = CheckBox.new()
			check_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			check_box.toggle_mode = true
			check_box.connect("toggled", _on_value_changed_bool.bind(field_name))
			hbox.add_child(check_box)
		else:
			var line_edit = LineEdit.new()
			line_edit.text = str(stat_data.get(field_name))
			line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			line_edit.connect("text_submitted", _on_value_changed.bind(field_name))
			hbox.add_child(line_edit)

	get_popup().hide()
	pressed.connect(_on_pressed)


func _on_pressed():
	var window: Window = $StatEditorWindow
	if window.visible:
		window.hide()
	else:
		window.position = global_position + Vector2(0, size.y)
		window.show()


func update_stat_modifiers(stat_modifiers: StatModifierData):
	if !stat_modifiers:
		stat_data = StatModifierData.new()
	else:
		stat_data = stat_modifiers

	var counter = 0
	for element in vbox.get_children():
		if element is HBoxContainer:
			for child in element.get_children():
				if child is Label:
					continue
				elif child is LineEdit:
					child.text = str(stat_data.get(field_names[counter]))
				elif child is CheckBox:
					child.button_pressed = stat_data.invulnerable
				counter+=1


func _on_value_changed_bool(value: bool, field_name):
	stat_data.set(field_name, value)


func _on_value_changed(new_text: String, field_name: String):
	var value = float(new_text)
	stat_data.set(field_name, value)


func get_stat_data():
	return stat_data
