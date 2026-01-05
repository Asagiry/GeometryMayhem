extends CanvasLayer

@export var transition_scene: PackedScene
@export var main_menu_scene: PackedScene

var transition_screen_instance

@onready var kills_value: Label = %KillsValue
@onready var dashes_value: Label = %DashesValue
@onready var parries_value: Label = %ParriesValue
@onready var artifacts_grid: GridContainer = %ArtifactsGrid

func _ready():
	transition_screen_instance = transition_scene.instantiate()
	transition_screen_instance.transitioned.connect(_on_transition_screen_transitioned)
	populate_data()

func _on_ok_button_pressed() -> void:
	get_tree().root.add_child(transition_screen_instance)
	transition_screen_instance.transition()


func _on_transition_screen_transitioned():
	Global.game_ended.emit()
	get_tree().change_scene_to_packed(main_menu_scene)
	transition_screen_instance.queue_free()


func populate_data() -> void:
	# Проверяем, существует ли скрипт статистики (чтобы не было краша при тесте сцены отдельно)
	if not Global.runtime_script:
		push_warning("RuntimeScript is missing inside Global!")
		return

	var stats = Global.runtime_script
	kills_value.text = str(stats.killed_creeps)
	dashes_value.text = str(stats.number_of_dashes)
	parries_value.text = str(stats.number_of_sucessfull_parry)
	for child in artifacts_grid.get_children():
		child.queue_free()
	for artefact: ArtefactData in stats.artefacts:
		add_artefact_icon(artefact)

func add_artefact_icon(data: ArtefactData) -> void:
	if data.icon == null:
		return
	var texture_rect = TextureRect.new()
	texture_rect.texture = data.icon
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.custom_minimum_size = Vector2(64, 64)
	texture_rect.tooltip_text = "%s\n%s" % [data.display_name, data.description]
	artifacts_grid.add_child(texture_rect)
