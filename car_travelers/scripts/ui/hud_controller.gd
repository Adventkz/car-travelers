# res://scripts/ui/hud_controller.gd
extends Control

@onready var fuel_bar: ProgressBar = $HUDContainer/FuelBar
@onready var food_bar: ProgressBar = $HUDContainer/FoodBar
@onready var stress_bar: ProgressBar = $HUDContainer/StressBar
@onready var vehicle_bar: ProgressBar = $HUDContainer/VehicleHPBar
@onready var fuel_label: Label = $HUDContainer/FuelBar/Label
@onready var food_label: Label = $HUDContainer/FoodBar/Label
@onready var stress_label: Label = $HUDContainer/StressBar/Label
@onready var vehicle_label: Label = $HUDContainer/VehicleHPBar/Label
@onready var day_label: Label = $HUDContainer/DayLabel
@onready var phase_label: Label = $HUDContainer/PhaseLabel

func _ready() -> void:
	EventBus.resource_changed.connect(_on_resource_changed)
	EventBus.day_ended.connect(_on_day_ended)
	EventBus.phase_changed.connect(_on_phase_changed)
	_refresh_all()

func _refresh_all() -> void:
	_set_bar("fuel", ResourceManager.fuel)
	_set_bar("food", ResourceManager.food)
	_set_bar("stress", ResourceManager.stress)
	_set_bar("vehicle_hp", ResourceManager.vehicle_hp)
	day_label.text = tr("DAY") + " %d" % GameState.day_count

func _on_resource_changed(type: String, value: int) -> void:
	_set_bar(type, value)

func _set_bar(type: String, value: int) -> void:
	match type:
		"fuel":
			fuel_bar.value = value
			fuel_label.text = str(value)
		"food":
			food_bar.value = value
			food_label.text = str(value)
		"stress":
			stress_bar.value = value
			stress_label.text = str(value)
		"vehicle_hp":
			vehicle_bar.value = value
			vehicle_label.text = str(value)

func _on_day_ended(_day: int) -> void:
	day_label.text = tr("DAY") + " %d" % GameState.day_count

func _on_phase_changed(phase: int) -> void:
	var names := ["MAP", "INCIDENT", "MANAGEMENT", "CAMP"]
	phase_label.text = tr(names[phase]) if phase < names.size() else ""
