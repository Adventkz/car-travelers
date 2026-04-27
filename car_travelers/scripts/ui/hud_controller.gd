# res://scripts/ui/hud_controller.gd
extends CanvasLayer

@onready var fuel_bar: ProgressBar = $HUDContainer/FuelVBox/FuelBar
@onready var food_bar: ProgressBar = $HUDContainer/FoodVBox/FoodBar
@onready var stress_bar: ProgressBar = $HUDContainer/StressVBox/StressBar
@onready var vehicle_bar: ProgressBar = $HUDContainer/VehicleVBox/VehicleHPBar
@onready var fuel_label: Label = $HUDContainer/FuelVBox/FuelBar/ValueLabel
@onready var food_label: Label = $HUDContainer/FoodVBox/FoodBar/ValueLabel
@onready var stress_label: Label = $HUDContainer/StressVBox/StressBar/ValueLabel
@onready var vehicle_label: Label = $HUDContainer/VehicleVBox/VehicleHPBar/ValueLabel
@onready var day_label: Label = $HUDContainer/DayLabel
@onready var phase_label: Label = $HUDContainer/PhaseLabel

# Опциональные узлы (если не существуют, игнорируем)
var menu_button: Button
var vehicle_manager_button: Button
var family_stats_button: Button
var resource_log_button: Button

const BAR_COLORS := {
	"fuel": Color(0.96, 0.65, 0.14, 1.0),      # F5A623 - оранжевый
	"food": Color(0.31, 0.8, 0.77, 1.0),      # 4ECDC4 - бирюзовый
	"stress": Color(0.91, 0.27, 0.38, 1.0),   # E94560 - красный
	"vehicle": Color(0.37, 0.38, 0.81, 1.0)    # 5E60CE - фиолетовый
}

func _ready() -> void:
	# Пытаемся найти опциональные узлы
	menu_button = $HUDContainer/MenuButton
	vehicle_manager_button = $HUDContainer/RightPanel/VehicleManagerButton
	family_stats_button = $HUDContainer/RightPanel/FamilyStatsButton
	resource_log_button = $HUDContainer/RightPanel/ResourceLogButton
	
	_apply_anime_style()
	
	EventBus.resource_changed.connect(_on_resource_changed)
	ResourceManager.resource_changed_with_delta.connect(_on_resource_changed_with_delta)
	EventBus.day_ended.connect(_on_day_ended)
	EventBus.phase_changed.connect(_on_phase_changed)
	EventBus.scene_transition.connect(_on_scene_transition)
	
	if menu_button:
		menu_button.pressed.connect(_on_menu_button)
	
	if vehicle_manager_button:
		vehicle_manager_button.pressed.connect(_on_vehicle_manager)
	
	if family_stats_button:
		family_stats_button.pressed.connect(_on_family_stats)
	
	if resource_log_button:
		resource_log_button.pressed.connect(_on_resource_log)
	
	_refresh_all()
	
	# Проверяем видимость с задержкой после загрузки сцены
	call_deferred("_check_visibility")

func _apply_anime_style() -> void:
	# Стилизация прогресс-баров
	_style_bar(fuel_bar, BAR_COLORS.fuel)
	_style_bar(food_bar, BAR_COLORS.food)
	_style_bar(stress_bar, BAR_COLORS.stress)
	_style_bar(vehicle_bar, BAR_COLORS.vehicle)
	
	# Стилизация меток баров
	_style_bar_label(fuel_label)
	_style_bar_label(food_label)
	_style_bar_label(stress_label)
	_style_bar_label(vehicle_label)
	
	# Стилизация информационных меток
	day_label.add_theme_font_size_override("font_size", 18)
	day_label.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 1.0))
	
	phase_label.add_theme_font_size_override("font_size", 16)
	phase_label.add_theme_color_override("font_color", Color(0.91, 0.27, 0.38, 1.0))
	
	if menu_button:
		_style_button(menu_button)

func _style_bar(bar: ProgressBar, color: Color) -> void:
	bar.custom_minimum_size = Vector2(140, 28)
	
	# Фон бара
	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.18, 0.8)
	bg_style.corner_radius_top_left = 6
	bg_style.corner_radius_top_right = 6
	bg_style.corner_radius_bottom_right = 6
	bg_style.corner_radius_bottom_left = 6
	bar.add_theme_stylebox_override("background", bg_style)
	
	# Заполнение бара
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = color
	fill_style.corner_radius_top_left = 6
	fill_style.corner_radius_top_right = 6
	fill_style.corner_radius_bottom_right = 6
	fill_style.corner_radius_bottom_left = 6
	bar.add_theme_stylebox_override("fill", fill_style)

func _style_bar_label(label: Label) -> void:
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))

func _style_button(btn: Button) -> void:
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.23, 0.27, 0.38, 0.9)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = Color(0.91, 0.27, 0.38, 0.6)
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_right = 8
	normal_style.corner_radius_bottom_left = 8
	btn.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style := normal_style.duplicate()
	hover_style.bg_color = Color(0.3, 0.35, 0.5, 0.95)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 1.0))

func _refresh_all() -> void:
	_set_bar("fuel", ResourceManager.fuel)
	_set_bar("food", ResourceManager.food)
	_set_bar("stress", ResourceManager.stress)
	_set_bar("vehicle_hp", ResourceManager.vehicle_hp)
	day_label.text = tr("DAY") + " %d" % GameState.day_count

func _on_resource_changed(type: String, value: int) -> void:
	_set_bar(type, value)

func _on_resource_changed_with_delta(type: String, value: int, delta: int, reason: String) -> void:
	_set_bar(type, value)
	# Показать всплывающее уведомление об изменении ресурса
	_show_resource_change_notification(type, delta, reason)

func _show_resource_change_notification(resource_type: String, delta: int, reason: String) -> void:
	var notification := Label.new()
	notification.text = "%s %+d (%s)" % [resource_type, delta, reason]
	notification.add_theme_font_size_override("font_size", 16)
	
	if delta > 0:
		notification.add_theme_color_override("font_color", Color(0.31, 0.8, 0.77, 1.0))  # Зелёный
	else:
		notification.add_theme_color_override("font_color", Color(0.91, 0.27, 0.38, 1.0))  # Красный
	
	notification.position = Vector2(20, 80)
	notification.z_index = 100
	add_child(notification)
	
	var tween := create_tween()
	tween.tween_property(notification, "position", notification.position + Vector2(0, -50), 2.0)
	tween.tween_property(notification, "modulate:a", 0.0, 1.0)
	tween.tween_callback(notification.queue_free)

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

func _on_menu_button() -> void:
	EventBus.scene_transition.emit("res://scenes/ui/MainMenu.tscn")

func _on_vehicle_manager() -> void:
	EventBus.scene_transition.emit("res://scenes/ui/VehicleUpgrade.tscn")

func _on_family_stats() -> void:
	EventBus.scene_transition.emit("res://scenes/ui/FamilyStats.tscn")

func _on_resource_log() -> void:
	EventBus.scene_transition.emit("res://scenes/ui/ResourceLog.tscn")

func _on_scene_transition(target: String) -> void:
	# Скрываем HUD в главном меню или экранах завершения игры
	if target == "res://scenes/ui/MainMenu.tscn" or \
	   target == "res://scenes/ui/GameOver.tscn" or \
	   target == "res://scenes/ui/Victory.tscn":
		hide()
	else:
		show()

func _check_visibility() -> void:
	var current_scene := get_tree().current_scene
	if not current_scene:
		return
	
	var scene_path := current_scene.scene_file_path
	if scene_path == "res://scenes/ui/MainMenu.tscn" or \
	   scene_path == "res://scenes/ui/GameOver.tscn" or \
	   scene_path == "res://scenes/ui/Victory.tscn":
		hide()
	else:
		show()
