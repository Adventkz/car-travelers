# res://scripts/gameplay/camp_controller.gd
extends Node

func _ready() -> void:
	pass

func start_camp_dialogue(dialogue_id: String) -> void:
	var path := "res://data/dialogues/camp/%s.dialogue" % dialogue_id
	var resource = load(path)
	if not resource:
		push_error("camp_controller: dialogue not found: %s" % path)
		return
	# DialogueManager из аддона
	if Engine.has_singleton("DialogueManager"):
		Engine.get_singleton("DialogueManager").show_dialogue_balloon(resource, "start")
	else:
		push_warning("camp_controller: DialogueManager not available")

func end_camp() -> void:
	ResourceManager.modify("stress", -5)
	GameState.advance_day()
	GameState.set_phase(GameState.Phase.MAP)
	EventBus.scene_transition.emit("res://scenes/gameplay/MapView.tscn")
