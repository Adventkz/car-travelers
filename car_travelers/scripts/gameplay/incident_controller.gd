# res://scripts/gameplay/incident_controller.gd
extends Node

var _pool: Array = []
var _current_incident: Dictionary = {}

signal incident_choices_ready(incident: Dictionary)

func _ready() -> void:
	_load_pool()

func _load_pool() -> void:
	_pool.clear()
	var paths := [
		"res://data/incidents/ch01_pool.json",
		"res://data/incidents/generic_pool.json"
	]
	if ResourceManager.fuel <= ResourceManager.CRITICAL_FUEL \
	or ResourceManager.food <= ResourceManager.CRITICAL_FOOD \
	or ResourceManager.stress >= ResourceManager.CRITICAL_STRESS:
		paths.append("res://data/incidents/critical_pool.json")

	for path in paths:
		var file := FileAccess.open(path, FileAccess.READ)
		if not file:
			continue
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK:
			_pool.append_array((json.data as Dictionary).get("incidents", []))
		file.close()

func start_random() -> void:
	_load_pool()
	if _pool.is_empty():
		push_warning("incident_controller: empty pool")
		_skip()
		return
	_current_incident = _pool[randi() % _pool.size()] as Dictionary
	EventBus.incident_started.emit(_current_incident.get("id", ""))
	incident_choices_ready.emit(_current_incident)

func resolve(choice_idx: int) -> void:
	if _current_incident.is_empty(): return
	var choices: Array = _current_incident.get("choices", [])
	if choice_idx >= choices.size(): return

	var choice: Dictionary = choices[choice_idx]
	var cost: Dictionary = choice.get("cost", {})
	for res_type in cost:
		ResourceManager.modify(res_type, int(cost[res_type]))

	var trait_signal: Dictionary = choice.get("trait_signal", {})
	if not trait_signal.is_empty():
		TraitSystem.reinforce(
			trait_signal.get("character", ""),
			trait_signal.get("trait", ""),
			int(trait_signal.get("delta", 0))
		)

	EventBus.incident_resolved.emit(_current_incident.get("id", ""), choice_idx)
	_current_incident = {}
	GameState.set_phase(GameState.Phase.MANAGEMENT)
	EventBus.scene_transition.emit("res://scenes/gameplay/ManagementPanel.tscn")

func _skip() -> void:
	GameState.set_phase(GameState.Phase.MANAGEMENT)
	EventBus.scene_transition.emit("res://scenes/gameplay/ManagementPanel.tscn")
