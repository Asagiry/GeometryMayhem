extends ColorRect

signal transition_complete()

var speed := 0.5
var progress := 0.0
var finished := false

func _ready():
	if material is ShaderMaterial:
		material.set_shader_parameter("progress", 0.0)

func _process(delta):
	if material is not ShaderMaterial or finished:
		return

	if progress != 1.0:
		progress += delta * speed
		progress = clamp(progress, 0.0, 1.0)
		material.set_shader_parameter("progress", progress)
	else:
		finished = true
		emit_signal("transition_complete")
