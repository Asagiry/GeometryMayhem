class_name SpecialEffectRegistry
extends Node

static var _registry: Dictionary = {}
static var _initialized := false

static func initialize():
	if _initialized:
		return
	_initialized = true
	var base_path := "res://scripts/data/effect/behavior"
	var dir := DirAccess.open(base_path)
	if dir == null:
		push_error("❌ SpecialEffectRegistry: папка %s не найдена" % base_path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".gd"):
			var path = "%s/%s" % [base_path, file_name]
			var script = load(path)
			if script:
				var _name = file_name.get_basename().to_upper() # "FREEZEEFFECT"
				# убираем слово EFFECT в конце для чистого ключа
				_name = _name.replace("_", "")
				_name = _name.replace("EFFECT", "")
				_registry[_name] = script
				print("✅ Registered special effect:", _name)
		file_name = dir.get_next()
	dir.list_dir_end()

static func create(effect_name: String) -> Node:
	initialize()
	effect_name = effect_name.to_upper()
	if not _registry.has(effect_name):
		push_warning("⚠️ No special effect class found for '%s'" % effect_name)
		return null
	return _registry[effect_name].new()
