# res://scripts/gameplay/camp_controller.gd
extends Node

func _ready() -> void:
	pass

func start_camp_dialogue(dialogue_id: String) -> void:
	var path := "res://data/dialogues/camp/%s.json" % dialogue_id
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("camp_controller: dialogue not found: %s" % path)
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		push_error("camp_controller: JSON parse error: %s" % path)
		return
	file.close()
	var data: Dictionary = json.data as Dictionary
	var lines: Array = data.get("lines", [])
	var view := _get_dialogue_view()
	if view:
		view.show_dialogue(dialogue_id, lines)
	else:
		push_warning("camp_controller: DialogueView autoload not found")

func end_camp() -> void:
	ResourceManager.modify("stress", -5)
	GameState.advance_day()
	GameState.set_phase(GameState.Phase.MAP)
	SaveManager.save_game()
	EventBus.scene_transition.emit("res://scenes/gameplay/MapView.tscn")

func _get_dialogue_view() -> Node:
	# DialogueView подключён как autoload или дочерняя сцена
	if Engine.has_singleton("DialogueView"):
		return Engine.get_singleton("DialogueView")
	var root := Engine.get_main_loop().root
	return root.find_child("DialogueView", true, false)
