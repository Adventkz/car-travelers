# res://scripts/core/SaveManager.gd
extends Node

const SAVE_PATH := "user://saves/save_01.json"

func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game() -> void:
	var data := {
		"version": 1,
		"day_count": GameState.day_count,
		"current_chapter": GameState.current_chapter,
		"current_node_id": GameState.current_node_id,
		"active_family": GameState.active_family,
		"parts_currency": GameState.parts_currency,
		"dialogue_flags": GameState.dialogue_flags,
		"resources": ResourceManager.get_all(),
		"traits": TraitSystem.serialize()
	}
	var dir := DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func load_game() -> void:
	if not save_exists():
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return
	file.close()
	var data: Dictionary = json.data as Dictionary

	GameState.day_count = data.get("day_count", 1)
	GameState.current_chapter = data.get("current_chapter", 1)
	GameState.current_node_id = data.get("current_node_id", "node_start")
	GameState.active_family = data.get("active_family", "family_a")
	GameState.parts_currency = data.get("parts_currency", 0)
	GameState.dialogue_flags = data.get("dialogue_flags", {})

	var res: Dictionary = data.get("resources", {})
	for key in res:
		ResourceManager.set(key, int(res[key]))

	TraitSystem.deserialize(data.get("traits", {}))

func reset() -> void:
	GameState.day_count = 1
	GameState.current_chapter = 1
	GameState.current_node_id = "node_start"
	GameState.active_family = "family_a"
	GameState.parts_currency = 0
	GameState.dialogue_flags = {}
	ResourceManager.fuel = ResourceManager.MAX_FUEL
	ResourceManager.food = ResourceManager.MAX_FOOD
	ResourceManager.stress = 0
	ResourceManager.vehicle_hp = ResourceManager.MAX_VEHICLE_HP
