# res://scripts/gameplay/management_panel.gd
extends Control

@onready var stats_label: Label = $VBox/StatsLabel
@onready var food_btn: Button = $VBox/FoodButton
@onready var vehicle_btn: Button = $VBox/VehicleButton
@onready var camp_btn: Button = $VBox/CampButton
@onready var map_btn: Button = $VBox/MapButton

var _controller: Node

func _ready() -> void:
	_controller = Node.new()
	_controller.set_script(load("res://scripts/gameplay/management_controller.gd"))
	add_child(_controller)

	food_btn.pressed.connect(_on_food)
	vehicle_btn.pressed.connect(_on_vehicle)
	camp_btn.pressed.connect(_controller.proceed_to_camp)
	map_btn.pressed.connect(_controller.proceed_to_map)
	EventBus.resource_changed.connect(func(_t, _v): _refresh_stats())
	_refresh_stats()

func _refresh_stats() -> void:
	var r := ResourceManager
	stats_label.text = "Топливо: %d  Еда: %d  Стресс: %d  Авто: %d" % [
		r.fuel, r.food, r.stress, r.vehicle_hp
	]

func _on_food() -> void:
	_controller.distribute_food(5)

func _on_vehicle() -> void:
	EventBus.scene_transition.emit("res://scenes/ui/VehicleUpgrade.tscn")
