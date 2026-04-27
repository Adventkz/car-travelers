# res://scripts/autoloads/ResourceManager.gd
extends Node

# --- Сигналы ---
signal resource_changed(resource_type: String, new_value: int)
signal resource_changed_with_delta(resource_type: String, new_value: int, delta: int, reason: String)
signal resource_critical(resource_type: String)

# --- Константы ---
const MAX_FUEL := 100
const MAX_FOOD := 100
const MAX_STRESS := 100
const MAX_VEHICLE_HP := 100

const CRITICAL_FUEL := 20
const CRITICAL_FOOD := 15
const CRITICAL_STRESS := 80
const CRITICAL_VEHICLE_HP := 25

# --- Состояние ---
var fuel: int = MAX_FUEL
var food: int = MAX_FOOD
var stress: int = 0
var vehicle_hp: int = MAX_VEHICLE_HP

var resource_log := []
var dialogue_log := []

# --- Публичные методы ---
func modify(resource_type: String, delta: int, reason: String = "") -> void:
	var old_value: int = get(resource_type)
	match resource_type:
		"fuel":  fuel  = clamp(fuel + delta,  0, MAX_FUEL)
		"food":  food  = clamp(food + delta,  0, MAX_FOOD)
		"stress": stress = clamp(stress + delta, 0, MAX_STRESS)
		"vehicle_hp": vehicle_hp = clamp(vehicle_hp + delta, 0, MAX_VEHICLE_HP)
	var new_value: int = get(resource_type)
	resource_changed.emit(resource_type, new_value)
	resource_changed_with_delta.emit(resource_type, new_value, delta, reason)
	_log_resource_change(resource_type, old_value, new_value, delta, reason)
	_check_critical(resource_type)

func _log_resource_change(resource_type: String, old_value: int, new_value: int, delta: int, reason: String) -> void:
	var log_entry := {
		"timestamp": Time.get_datetime_string_from_system(false),
		"resource": resource_type,
		"old_value": old_value,
		"new_value": new_value,
		"delta": delta,
		"reason": reason
	}
	resource_log.append(log_entry)
	print("Ресурс %s: %d → %d (%+d) - %s" % [resource_type, old_value, new_value, delta, reason])

func get_value(resource_type: String) -> int:
	return get(resource_type) as int

func _check_critical(resource_type: String) -> void:
	var is_critical := false
	match resource_type:
		"fuel":       is_critical = fuel <= CRITICAL_FUEL
		"food":       is_critical = food <= CRITICAL_FOOD
		"stress":     is_critical = stress >= CRITICAL_STRESS
		"vehicle_hp": is_critical = vehicle_hp <= CRITICAL_VEHICLE_HP
	if is_critical:
		resource_critical.emit(resource_type)
		EventBus.resource_critical.emit(resource_type)

func calculate_fuel_cost(distance_km: float, terrain: String) -> int:
	var terrain_mod: int = 0
	match terrain:
		"asphalt": terrain_mod = 0
		"dirt":    terrain_mod = 5
		"mountain":terrain_mod = 12
		"sand":    terrain_mod = 8
	var vehicle_penalty: float = 0.0
	if vehicle_hp < 50:
		vehicle_penalty = (50.0 - vehicle_hp) * 0.1
	return int(distance_km * 0.8 + terrain_mod + vehicle_penalty)

func calculate_stress_delta() -> int:
	var base := 3
	# comfort_bonus — TODO при апгрейдах авто
	var food_bonus: int = 0
	if food > 60:
		food_bonus = 2
	elif food <= 30:
		food_bonus = -3
	return base - food_bonus

func get_all() -> Dictionary:
	return { "fuel": fuel, "food": food, "stress": stress, "vehicle_hp": vehicle_hp }

func get_resource_log() -> Array:
	return resource_log.duplicate()

func clear_resource_log() -> void:
	resource_log.clear()

func add_dialogue_log(entry: Dictionary) -> void:
	dialogue_log.append(entry)
	print("Диалог лог: %s с %s" % [entry.get("type", ""), entry.get("character", "")])

func get_dialogue_log() -> Array:
	return dialogue_log.duplicate()

func clear_dialogue_log() -> void:
	dialogue_log.clear()
