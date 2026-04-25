# res://scripts/autoloads/GameState.gd
extends Node

enum Phase { MAP = 0, INCIDENT = 1, MANAGEMENT = 2, CAMP = 3 }

var current_phase: Phase = Phase.MAP
var current_chapter: int = 1
var current_node_id: String = "node_start"
var day_count: int = 1
var parts_currency: int = 0
var active_family: String = "family_a"
var dialogue_flags: Dictionary = {}
var vehicle: VehicleState = VehicleState.new()

func _ready() -> void:
	EventBus.scene_transition.connect(_on_scene_transition)

func set_phase(phase: Phase) -> void:
	current_phase = phase
	EventBus.phase_changed.emit(phase)

func set_flag(key: String, value: bool) -> void:
	dialogue_flags[key] = value

func get_flag(key: String) -> bool:
	return dialogue_flags.get(key, false)

func advance_day() -> void:
	day_count += 1
	EventBus.day_ended.emit(day_count - 1)

func _on_scene_transition(target: String) -> void:
	get_tree().change_scene_to_file(target)
