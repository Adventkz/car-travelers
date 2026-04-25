# res://scripts/core/RouteData.gd
class_name RouteData
extends Resource

@export var node_id: String = ""
@export var display_name: String = ""
@export var distance_km: float = 0.0
@export var terrain: String = "asphalt"  # asphalt | dirt | mountain | sand
@export var incident_chance: float = 0.6
@export var connected_nodes: Array[String] = []
@export var position: Vector2 = Vector2.ZERO
