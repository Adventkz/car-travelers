# res://scripts/core/VehicleState.gd
class_name VehicleState
extends Resource

@export var hp: int = 100
@export var fuel_capacity: int = 100
@export var upgrades: Dictionary = {
	"comfort": 0,
	"fuel_tank": 0,
	"cargo": 0,
	"engine": 0,
	"repair_kit": 0,
	"solar_panel": 0
}
@export var cosmetics: Dictionary = {
	"paint": "default",
	"roof_rack": false,
	"antenna": false
}

const MAX_UPGRADE_LEVEL := {
	"comfort": 5,
	"fuel_tank": 3,
	"cargo": 3,
	"engine": 3,
	"repair_kit": 2,
	"solar_panel": 1
}

const UPGRADE_COSTS := {
	"comfort": [20, 40, 80, 120, 160],
	"fuel_tank": [30, 60, 120],
	"cargo": [25, 50, 100],
	"engine": [35, 70, 140],
	"repair_kit": [40, 80],
	"solar_panel": [60]
}

func get_upgrade_level(upgrade_id: String) -> int:
	return upgrades.get(upgrade_id, 0)

func can_upgrade(upgrade_id: String, parts: int) -> bool:
	var current_level: int = get_upgrade_level(upgrade_id)
	var max_level: int = MAX_UPGRADE_LEVEL.get(upgrade_id, 0)
	if current_level >= max_level:
		return false
	var cost := get_upgrade_cost(upgrade_id)
	return parts >= cost

func get_upgrade_cost(upgrade_id: String) -> int:
	var current_level := get_upgrade_level(upgrade_id)
	var costs: Array = UPGRADE_COSTS.get(upgrade_id, [])
	if current_level >= costs.size():
		return 999999
	return costs[current_level]

func upgrade(upgrade_id: String) -> void:
	var current_level: int = get_upgrade_level(upgrade_id)
	var max_level: int = MAX_UPGRADE_LEVEL.get(upgrade_id, 0)
	if current_level < max_level:
		upgrades[upgrade_id] = current_level + 1
		_apply_upgrade_effects(upgrade_id)

func _apply_upgrade_effects(upgrade_id: String) -> void:
	match upgrade_id:
		"fuel_tank":
			fuel_capacity = 100 + upgrades["fuel_tank"] * 20
		"repair_kit":
			if upgrades["repair_kit"] > 0:
				hp = min(hp + 5, 100)

func get_fuel_efficiency_bonus() -> float:
	var engine_level: int = upgrades.get("engine", 0)
	return engine_level * 0.1

func get_comfort_bonus() -> int:
	return upgrades.get("comfort", 0) * 2

func get_max_food_capacity() -> int:
	return 100 + upgrades.get("cargo", 0) * 15

func serialize() -> Dictionary:
	return {
		"hp": hp,
		"fuel_capacity": fuel_capacity,
		"upgrades": upgrades.duplicate(),
		"cosmetics": cosmetics.duplicate()
	}

func deserialize(data: Dictionary) -> void:
	hp = data.get("hp", 100)
	fuel_capacity = data.get("fuel_capacity", 100)
	upgrades = data.get("upgrades", {}).duplicate()
	cosmetics = data.get("cosmetics", {}).duplicate()
