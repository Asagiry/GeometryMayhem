class_name PlayerArtefact

extends Node

#Класс обертка, чтобы не изменять статический ресурс.
#Если положить equipped в ArtefactData - это изменяемое поле
#Это плохо - изменять статический ресурс.
var artefact: ArtefactData
var equipped: bool = false
var level: int = 1
