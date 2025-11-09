extends Node

@export var transition_end_screen: PackedScene

var pause_menu_scene = preload("res://scene/UI/pause_menu/pause_menu.tscn")

@onready var camera_2d: Camera2D = $Camera2D

func _ready() -> void:
	Global.player_died.connect(_on_player_died)

func _input(event):
	if event.is_action_pressed("pause"):
		add_child(pause_menu_scene.instantiate())


func _on_player_died():
	var screen = transition_end_screen.instantiate() as DeathScreen
	add_child(screen)

	# Получаем размер видимой области камеры
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_visible_size = viewport_size / camera_2d.zoom

	# Добавляем отступы со всех сторон (можно регулировать значение)
	var margin = 25/camera_2d.zoom.x  # или любой другой размер отступа
	var expanded_size = camera_visible_size + Vector2(margin * 2, margin * 2)

	# Центрируем screen в позиции камеры
	screen.global_position = camera_2d.global_position

	# Устанавливаем увеличенный размер color_rect и центрируем его
	screen.color_rect.size = expanded_size
	screen.color_rect.position = -expanded_size / 2  # центрируем относительно родителя
	screen.color_rect.scale = Vector2.ONE
