class_name ArtefactDatabase

extends Node

@export var artefacts_folder: String = "res://resource/artefacts/"

var _artefacts := {}

func _ready() -> void:
	_load_artefacts()


func _load_artefacts() -> void:
	var dir := DirAccess.open(artefacts_folder)
	if dir == null:
		push_error("Не удалось открыть папку: %s" % artefacts_folder)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var path = artefacts_folder + file_name
			var artefact_res: Resource = load(path)

			if artefact_res == null:
				push_warning("Не удалось загрузить артефакт: %s" % path)
			elif not artefact_res.has_method("get"):
				push_warning("Файл не является ресурсом артефакта: %s" % path)
			else:
				# Сохраняем в кэш по id (O(1) доступ)
				_artefacts[artefact_res.id] = artefact_res

		file_name = dir.get_next()

	dir.list_dir_end()
	print("Загружено артефактов: ", _artefacts.size())


func get_artefact_by_id(id: String) -> Resource:
	return _artefacts.get(id)


func has_artefact(id: String) -> bool:
	return _artefacts.has(id)


func get_all_artefacts() -> Array:
	return _artefacts.values()


func get_random_accessible_artefact(rarity: Util.ArtefactRarity):
	var candidates: Array[ArtefactData] = []
	var player_level = Global.meta_progression.player_data.level
	for artefact in _artefacts.values():
		if artefact.rarity != rarity:
			continue
		if artefact.level_requirement > player_level:
			continue
		if Global.inventory.has_artefact(artefact.id):
			continue
		candidates.append(artefact)
	if candidates.is_empty():
		return null
	return candidates.pick_random()
