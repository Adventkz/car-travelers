# res://scripts/ui/vehicle_upgrade_view.gd
extends Control

@onready var parts_label := $Panel/VBoxContainer/PartsLabel
@onready var upgrades_container := $Panel/VBoxContainer/ScrollContainer/UpgradesContainer
@onready var close_button := $CloseButton

var _upgrade_buttons := {}

func _ready() -> void:
	close_button.pressed.connect(_on_back_to_management)
	_create_upgrade_ui()
	_refresh_ui()

func _create_upgrade_ui() -> void:
	var vehicle := GameState.vehicle
	var upgrade_ids := ["comfort", "fuel_tank", "cargo", "engine", "repair_kit", "solar_panel"]
	
	var upgrade_names := {
		"comfort": "Комфорт",
		"fuel_tank": "Топливный бак",
		"cargo": "Грузовой отсек",
		"engine": "Двигатель",
		"repair_kit": "Рем. комплект",
		"solar_panel": "Солнечная панель"
	}
	
	for upgrade_id in upgrade_ids:
		var upgrade_row := HBoxContainer.new()
		upgrade_row.name = upgrade_id
		
		var name_label := Label.new()
		name_label.text = upgrade_names.get(upgrade_id, upgrade_id)
		name_label.custom_minimum_size = Vector2(200, 0)
		name_label.add_theme_font_size_override("font_size", 20)
		
		var level_label := Label.new()
		level_label.name = "LevelLabel"
		level_label.custom_minimum_size = Vector2(100, 0)
		level_label.add_theme_font_size_override("font_size", 18)
		
		var cost_label := Label.new()
		cost_label.name = "CostLabel"
		cost_label.custom_minimum_size = Vector2(100, 0)
		cost_label.add_theme_font_size_override("font_size", 18)
		
		var buy_button := Button.new()
		buy_button.name = "BuyButton"
		buy_button.text = "Купить"
		buy_button.custom_minimum_size = Vector2(120, 40)
		buy_button.add_theme_font_size_override("font_size", 18)
		buy_button.pressed.connect(_on_buy_upgrade.bind(upgrade_id))
		
		upgrade_row.add_child(name_label)
		upgrade_row.add_child(level_label)
		upgrade_row.add_child(cost_label)
		upgrade_row.add_child(buy_button)
		
		upgrades_container.add_child(upgrade_row)
		_upgrade_buttons[upgrade_id] = upgrade_row

func _refresh_ui() -> void:
	var vehicle := GameState.vehicle
	parts_label.text = "Запчасти: " + str(GameState.parts_currency)
	
	for upgrade_id in _upgrade_buttons:
		var row: HBoxContainer = _upgrade_buttons[upgrade_id]
		var level_label: Label = row.get_node("LevelLabel")
		var cost_label: Label = row.get_node("CostLabel")
		var buy_button: Button = row.get_node("BuyButton")
		
		var current_level: int = vehicle.get_upgrade_level(upgrade_id)
		var max_level: int = vehicle.MAX_UPGRADE_LEVEL.get(upgrade_id, 0)
		var cost: int = vehicle.get_upgrade_cost(upgrade_id)
		
		level_label.text = "Уровень: " + str(current_level) + "/" + str(max_level)
		
		if current_level >= max_level:
			cost_label.text = "МАКС"
			buy_button.disabled = true
		else:
			cost_label.text = "Цена: " + str(cost)
			buy_button.disabled = not vehicle.can_upgrade(upgrade_id, GameState.parts_currency)

func _on_buy_upgrade(upgrade_id: String) -> void:
	var controller := get_node_or_null("/root/VehicleUpgradeController")
	if controller:
		if controller.purchase_upgrade(upgrade_id):
			# Звуки отключены
			_refresh_ui()
		else:
			# Звуки отключены
			pass

func _on_back_to_management() -> void:
	# Звуки отключены
	EventBus.scene_transition.emit("res://scenes/gameplay/ManagementPanel.tscn")
