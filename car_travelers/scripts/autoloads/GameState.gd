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
var previous_scene: String = ""
var game_over: bool = false
var game_won: bool = false

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

func set_previous_scene(scene: String) -> void:
	previous_scene = scene

func get_previous_scene() -> String:
	return previous_scene

func set_game_over(won: bool) -> void:
	game_over = true
	game_won = won

func is_game_over() -> bool:
	return game_over

func reset_game() -> void:
	current_phase = Phase.MAP
	current_chapter = 1
	current_node_id = "node_start"
	day_count = 1
	parts_currency = 0
	dialogue_flags.clear()
	previous_scene = ""
	game_over = false
	game_won = false
	ResourceManager.fuel = ResourceManager.MAX_FUEL
	ResourceManager.food = ResourceManager.MAX_FOOD
	ResourceManager.stress = 0
	ResourceManager.vehicle_hp = ResourceManager.MAX_VEHICLE_HP
	ResourceManager.clear_resource_log()
	ResourceManager.clear_dialogue_log()

func _on_scene_transition(target: String) -> void:
	previous_scene = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(target)
