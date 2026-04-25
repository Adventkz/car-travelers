# res://scripts/autoloads/CharacterRegistry.gd
# Загружает данные всех персонажей из data/characters/*.json
extends Node

var _registry: Dictionary = {}

func _ready() -> void:
	_load_all()

func _load_all() -> void:
	var dir := DirAccess.open("res://data/characters/")
	if not dir:
		push_error("CharacterRegistry: cannot open data/characters/")
		return
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if fname.ends_with(".json"):
			_load_file("res://data/characters/" + fname)
		fname = dir.get_next()
	dir.list_dir_end()

func _load_file(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return
	file.close()
	var data: Dictionary = json.data as Dictionary
	var cid: String = data.get("char_id", "")
	if cid != "":
		_registry[cid] = data

func get_data(char_id: String) -> Dictionary:
	return _registry.get(char_id, {})

func get_all() -> Dictionary:
	return _registry.duplicate()

func get_family(family_id: String) -> Array:
	var result: Array = []
	for cid in _registry:
		if (_registry[cid] as Dictionary).get("family_id", "") == family_id:
			result.append(_registry[cid])
	return result
