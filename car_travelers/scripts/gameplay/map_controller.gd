# res://scripts/gameplay/map_controller.gd
extends Node

var _route_nodes: Array = []
var _current_node: Dictionary = {}

func _ready() -> void:
	_load_route()
	EventBus.scene_transition.connect(func(_t): pass)

func _load_route() -> void:
	var file := FileAccess.open("res://data/routes/chapter_01.json", FileAccess.READ)
	if not file:
		push_error("map_controller: cannot open chapter_01.json")
		return
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("map_controller: JSON parse error")
		return
	_route_nodes = (json.data as Dictionary).get("nodes", [])

func select_node(node_id: String) -> void:
	for node in _route_nodes:
		if node.get("node_id") == node_id:
			_current_node = node
			GameState.current_node_id = node_id
			_travel_to_node(node)
			return
	push_warning("map_controller: node not found: %s" % node_id)

func _travel_to_node(node: Dictionary) -> void:
	var fuel_cost := ResourceManager.calculate_fuel_cost(
		float(node.get("distance_km", 0)),
		node.get("terrain", "asphalt")
	)
	ResourceManager.modify("fuel", -fuel_cost)
	ResourceManager.modify("stress", ResourceManager.calculate_stress_delta())

	var roll := randf()
	var chance: float = node.get("incident_chance", 0.6)
	if roll < chance:
		GameState.set_phase(GameState.Phase.INCIDENT)
		EventBus.scene_transition.emit("res://scenes/gameplay/IncidentScene.tscn")
	else:
		GameState.set_phase(GameState.Phase.MANAGEMENT)
		EventBus.scene_transition.emit("res://scenes/gameplay/ManagementPanel.tscn")
