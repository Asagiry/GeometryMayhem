extends MenuButton

@export var stat_data: StatModifierData

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

	var vbox = VBoxContainer.new()
	window.add_child(vbox)

	# создаём элементы для каждого поля
	for field_name in [
		"speed_multiplier",
		"attack_multiplier",
		"armor_multiplier",
		"forward_receiving_damage_multiplier",
		"attack_cd_multiplier",
		"attack_duration_multiplier"
	]:
		var hbox = HBoxContainer.new()
		vbox.add_child(hbox)

		var label = Label.new()
		label.text = field_name
		label.custom_minimum_size.x = 180
		hbox.add_child(label)

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


func _on_value_changed(new_text: String, field_name: String):
	var value = float(new_text)
	stat_data.set(field_name, value)


func get_stat_data():
	return stat_data
