class_name ArtefactSlot
extends Control

signal artefact_selected(artefact_slot, player_artefact)

@export var shake_intensity: float = 3.5
@export var shake_duration: float = 0.15

var player_artefact: PlayerArtefact
var _tween: Tween
var stop_tween: bool = true
var start_tween: bool = true

@onready var texture_button: TextureButton = %TextureButton

func _ready():
	texture_button.mouse_entered.connect(_on_mouse_entered)
	texture_button.mouse_exited.connect(_on_mouse_exited)


func setup_slot(player_art: PlayerArtefact = player_artefact):
	player_artefact = player_art

	if player_artefact == null:
		texture_button.texture_normal = null
		return

	texture_button.texture_normal = player_artefact.artefact.icon


func start_shake(shake_intensity_import = shake_intensity):
	if not start_tween:
		return
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_loops() 
	scale = Vector2(1.1, 1.1)
	var base_rotation := rotation
	var base_scale := scale
	var rotation_amplitude := deg_to_rad(shake_intensity_import)                   

	_tween.tween_property(self, "rotation", base_rotation + rotation_amplitude, shake_duration * 0.5)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

	_tween.tween_property(self, "rotation", base_rotation - rotation_amplitude, shake_duration)\
		.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

	_tween.tween_property(self, "rotation", base_rotation, shake_duration * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func stop_shake(not_stop_shake_status = null):
	if not stop_tween:
		return
	scale = Vector2(1.0, 1.0)
	if _tween:
		_tween.kill()
	_tween = null
	rotation = 0
	scale = Vector2.ONE


func _on_texture_button_pressed() -> void:
	artefact_selected.emit(self, player_artefact)


func _on_mouse_entered():
	start_shake()


func _on_mouse_exited():
	stop_shake()
