# res://scripts/ui/game_history.gd
extends Control

@onready var title_label: Label = $VBoxContainer/Title
@onready var history_list: VBoxContainer = $VBoxContainer/ScrollContainer/HistoryList
@onready var back_button: Button = $VBoxContainer/BackButton

const HISTORY_PATH := "user://saves/game_history.json"
const MAX_HISTORY := 10

func _ready() -> void:
	_apply_anime_style()
	_load_history()
	
	back_button.pressed.connect(_on_back)

func _apply_anime_style() -> void:
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color(0.91, 0.27, 0.38, 1.0))
	
	_style_back_button(back_button)

func _style_back_button(btn: Button) -> void:
	btn.custom_minimum_size = Vector2(0, 60)
	
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.23, 0.27, 0.38, 0.9)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = Color(0.91, 0.27, 0.38, 0.6)
	normal_style.corner_radius_top_left = 12
	normal_style.corner_radius_top_right = 12
	normal_style.corner_radius_bottom_right = 12
	normal_style.corner_radius_bottom_left = 12
	btn.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style := normal_style.duplicate()
	hover_style.bg_color = Color(0.3, 0.35, 0.5, 0.95)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 1.0))

func _load_history() -> void:
	var file := FileAccess.open(HISTORY_PATH, FileAccess.READ)
	if not file:
		# Если истории нет, покажем сообщение
		var empty_label := Label.new()
		empty_label.text = "История игр пуста"
		empty_label.add_theme_font_size_override("font_size", 20)
		empty_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.94, 1.0))
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		history_list.add_child(empty_label)
		return
	
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return
	
	file.close()
	
	var data: Dictionary = json.data as Dictionary
	var history: Array = data.get("games", [])
	
	if history.is_empty():
		var empty_label := Label.new()
		empty_label.text = "История игр пуста"
		empty_label.add_theme_font_size_override("font_size", 20)
		empty_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.94, 1.0))
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		history_list.add_child(empty_label)
		return
	
	# Показываем последние 10 игр (от новых к старым)
	for i in range(min(history.size(), MAX_HISTORY)):
		var game_data: Dictionary = history[i] as Dictionary
		_create_history_entry(game_data, i + 1)

func _create_history_entry(data: Dictionary, index: int) -> void:
	var entry := PanelContainer.new()
	entry.custom_minimum_size = Vector2(0, 80)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	
	var header := HBoxContainer.new()
	
	var index_label := Label.new()
	index_label.text = "#%d" % index
	index_label.custom_minimum_size = Vector2(50, 0)
	index_label.add_theme_font_size_override("font_size", 18)
	index_label.add_theme_color_override("font_color", Color(0.91, 0.27, 0.38, 1.0))
	
	var date_label := Label.new()
	date_label.text = data.get("date", "---")
	date_label.add_theme_font_size_override("font_size", 16)
	date_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.94, 1.0))
	
	var result_label := Label.new()
	var won: bool = data.get("won", false)
	result_label.text = "ПОБЕДА" if won else "ПОРАЖЕНИЕ"
	result_label.add_theme_font_size_override("font_size", 16)
	result_label.add_theme_color_override("font_color", Color(0.31, 0.8, 0.77, 1.0) if won else Color(0.91, 0.27, 0.38, 1.0))
	
	header.add_child(index_label)
	header.add_child(date_label)
	header.add_child(result_label)
	
	var details_label := Label.new()
	details_label.text = "Дней: %d | Семья: %s | Причина: %s" % [
		data.get("day", 0),
		data.get("family", "---"),
		data.get("reason", "---")
	]
	details_label.add_theme_font_size_override("font_size", 14)
	details_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85, 1.0))
	
	vbox.add_child(header)
	vbox.add_child(details_label)
	entry.add_child(vbox)
	
	# Стилизация панели
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.37, 0.38, 0.81, 0.5)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.corner_radius_bottom_left = 8
	entry.add_theme_stylebox_override("panel", panel_style)
	
	history_list.add_child(entry)

func _on_back() -> void:
	EventBus.scene_transition.emit("res://scenes/ui/MainMenu.tscn")
