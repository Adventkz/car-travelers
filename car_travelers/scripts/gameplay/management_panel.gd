# res://scripts/gameplay/management_panel.gd
extends Control

@onready var title_label: Label = $VBox/Title
@onready var stats_label: Label = $VBox/StatsLabel
@onready var food_btn: Button = $VBox/FoodButton
@onready var vehicle_btn: Button = $VBox/VehicleButton
@onready var camp_btn: Button = $VBox/CampButton
@onready var map_btn: Button = $VBox/MapButton

var _controller: Node

func _ready() -> void:
	_apply_anime_style()
	
	_controller = Node.new()
	_controller.set_script(load("res://scripts/gameplay/management_controller.gd"))
	add_child(_controller)

	food_btn.pressed.connect(_on_food)
	vehicle_btn.pressed.connect(_on_vehicle)
	camp_btn.pressed.connect(_controller.proceed_to_camp)
	map_btn.pressed.connect(_controller.proceed_to_map)
	EventBus.resource_changed.connect(func(_t, _v): _refresh_stats())
	_refresh_stats()

func _apply_anime_style() -> void:
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color(0.91, 0.27, 0.38, 1.0))
	
	stats_label.add_theme_font_size_override("font_size", 18)
	stats_label.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 1.0))
	
	_style_management_button(food_btn, Color(0.31, 0.8, 0.77, 0.9))
	_style_management_button(vehicle_btn, Color(0.37, 0.38, 0.81, 0.9))
	_style_management_button(camp_btn, Color(0.96, 0.65, 0.14, 0.9))
	_style_management_button(map_btn, Color(0.91, 0.27, 0.38, 0.9))

func _style_management_button(btn: Button, color: Color) -> void:
	btn.custom_minimum_size = Vector2(0, 50)
	
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = color
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = color
	normal_style.corner_radius_top_left = 10
	normal_style.corner_radius_top_right = 10
	normal_style.corner_radius_bottom_right = 10
	normal_style.corner_radius_bottom_left = 10
	btn.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style := normal_style.duplicate()
	hover_style.bg_color = color.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.2)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))

func _refresh_stats() -> void:
	var r := ResourceManager
	stats_label.text = "Топливо: %d  Еда: %d  Стресс: %d  Авто: %d" % [
		r.fuel, r.food, r.stress, r.vehicle_hp
	]

func _on_food() -> void:
	_controller.distribute_food(5)

func _on_vehicle() -> void:
	EventBus.scene_transition.emit("res://scenes/ui/VehicleUpgrade.tscn")
