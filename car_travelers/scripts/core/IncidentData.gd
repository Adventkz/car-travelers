# res://scripts/core/IncidentData.gd
class_name IncidentData
extends Resource

@export var incident_id: String = ""
@export var title: String = ""
@export var description: String = ""
@export var trigger: String = "random"  # "random" | "route_node" | "resource_threshold"
@export var choices: Array = []         # Array of Dictionaries
@export var required_phase: int = 1     # Phase.INCIDENT
