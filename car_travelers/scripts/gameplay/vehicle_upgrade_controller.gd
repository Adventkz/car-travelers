# res://scripts/gameplay/vehicle_upgrade_controller.gd
extends Node

signal upgrade_panel_ready(upgrades: Dictionary)

func _ready() -> void:
	_refresh_ui()

func get_available_upgrades() -> Dictionary:
	var available := {}
	var vehicle := GameState.vehicle
	for upgrade_id in vehicle.MAX_UPGRADE_LEVEL:
		var current_level: int = vehicle.get_upgrade_level(upgrade_id)
		var max_level: int = vehicle.MAX_UPGRADE_LEVEL[upgrade_id]
		var cost: int = vehicle.get_upgrade_cost(upgrade_id)
		var can_afford: bool = GameState.parts_currency >= cost
		var can_upgrade: bool = current_level < max_level
		
		available[upgrade_id] = {
			"current_level": current_level,
			"max_level": max_level,
			"cost": cost,
			"can_afford": can_afford,
			"can_upgrade": can_upgrade
		}
	return available

func purchase_upgrade(upgrade_id: String) -> bool:
	var vehicle := GameState.vehicle
	if not vehicle.can_upgrade(upgrade_id, GameState.parts_currency):
		return false
	
	var cost := vehicle.get_upgrade_cost(upgrade_id)
	GameState.parts_currency -= cost
	vehicle.upgrade(upgrade_id)
	SaveManager.save_game()
	_refresh_ui()
	return true

func _refresh_ui() -> void:
	upgrade_panel_ready.emit(get_available_upgrades())
