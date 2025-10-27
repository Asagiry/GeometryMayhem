class_name SpecialEffectBehavior

extends Node

var _receiver: EffectReceiver
var _effect: Effect
var _elapsed_time: float = 0.0

func apply(receiver: EffectReceiver, effect: Effect) -> void:
	"""
	Запускает эффект.
	receiver — существо, на которое накладывается эффект.
	effect — сам ресурс эффекта.
	"""
	_receiver = receiver
	_effect = effect
	_elapsed_time = 0.0

	set_process(true)

func _process(delta: float) -> void:
	_elapsed_time += delta
	if _elapsed_time >= _effect.duration:
		end()
	else:
		tick(delta)

func tick(delta: float) -> void:
	"""
	Переопределяется в наследниках.
	Выполняется каждый кадр, пока эффект активен.
	"""
	pass

func end() -> void:
	"""
	Вызывается при завершении эффекта.
	Должен обязательно вызывать queue_free().
	"""
	set_process(false)
	queue_free()
