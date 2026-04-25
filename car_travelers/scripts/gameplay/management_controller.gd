# res://scripts/gameplay/management_controller.gd
extends Node

signal management_done

func distribute_food(amount: int) -> void:
	ResourceManager.modify("food", -amount)
	ResourceManager.modify("stress", -2)

func repair_vehicle(amount: int) -> void:
	# TODO: стоимость в parts_currency
	ResourceManager.modify("vehicle_hp", amount)

func proceed_to_camp() -> void:
	GameState.set_phase(GameState.Phase.CAMP)
	EventBus.scene_transition.emit("res://scenes/gameplay/CampScene.tscn")

func proceed_to_map() -> void:
	GameState.set_phase(GameState.Phase.MAP)
	EventBus.scene_transition.emit("res://scenes/gameplay/MapView.tscn")
