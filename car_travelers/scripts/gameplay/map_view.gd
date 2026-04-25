# res://scripts/gameplay/map_view.gd
extends Node2D

@onready var nodes_container: Node2D = $NodesContainer
@onready var info_label: Label = $InfoPanel/InfoLabel

var _controller: Node

func _ready() -> void:
	_controller = Node.new()
	_controller.set_script(load("res://scripts/gameplay/map_controller.gd"))
	add_child(_controller)
	_build_map_ui()

func _build_map_ui() -> void:
	var file := FileAccess.open("res://data/routes/chapter_01.json", FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return
	file.close()

	var nodes: Array = (json.data as Dictionary).get("nodes", [])
	for node_data in nodes:
		var pos: Array = node_data.get("position", [0, 0])
		var btn := Button.new()
		btn.text = node_data.get("display_name", "")
		btn.position = Vector2(pos[0], pos[1])
		btn.custom_minimum_size = Vector2(120, 40)
		var node_id: String = node_data.get("node_id", "")
		btn.pressed.connect(_on_node_selected.bind(node_id, node_data))
		nodes_container.add_child(btn)

func _on_node_selected(node_id: String, node_data: Dictionary) -> void:
	var terrain: String = node_data.get("terrain", "asphalt")
	var dist: float = float(node_data.get("distance_km", 0))
	var cost := ResourceManager.calculate_fuel_cost(dist, terrain)
	info_label.text = "%s — %d км (%s), топлива: -%d" % [
		node_data.get("display_name", node_id), int(dist), terrain, cost
	]
	_controller.select_node(node_id)
	SaveManager.save_game()
