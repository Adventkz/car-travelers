# res://scripts/ui/resource_log.gd
extends Control

@onready var title_label: Label = $VBoxContainer/Title
@onready var log_list: VBoxContainer = $VBoxContainer/ScrollContainer/LogList
@onready var back_button: Button = $VBoxContainer/BackButton
@onready var clear_button: Button = $VBoxContainer/ClearButton
@onready var tab_container: TabContainer = $VBoxContainer/TabContainer

func _ready() -> void:
	_apply_anime_style()
	tab_container.set_tab_title(0, "Ресурсы")
	tab_container.set_tab_title(1, "Диалоги")
	tab_container.tab_changed.connect(_on_tab_changed)
	_load_resource_log()
	
	back_button.pressed.connect(_on_back)
	clear_button.pressed.connect(_on_clear)

func _apply_anime_style() -> void:
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color(0.91, 0.27, 0.38, 1.0))
	
	_style_back_button(back_button)
	_style_clear_button(clear_button)

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

func _style_clear_button(btn: Button) -> void:
	btn.custom_minimum_size = Vector2(0, 50)
	
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.91, 0.27, 0.38, 0.9)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = Color(0.91, 0.27, 0.38, 1.0)
	normal_style.corner_radius_top_left = 10
	normal_style.corner_radius_top_right = 10
	normal_style.corner_radius_bottom_right = 10
	normal_style.corner_radius_bottom_left = 10
	btn.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style := normal_style.duplicate()
	hover_style.bg_color = Color(1.0, 0.4, 0.5, 0.95)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))

func _load_resource_log() -> void:
	for child in log_list.get_children():
		child.queue_free()
	
	var log: Array = ResourceManager.get_resource_log()
	
	if log.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Лог пуст"
		empty_label.add_theme_font_size_override("font_size", 20)
		empty_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.94, 1.0))
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		log_list.add_child(empty_label)
		return
	
	# Показываем последние записи (от новых к старым)
	for i in range(log.size() - 1, -1, -1):
		var entry: Dictionary = log[i] as Dictionary
		_create_log_entry(entry, log.size() - i)

func _create_log_entry(entry: Dictionary, index: int) -> void:
	var resource: String = entry.get("resource", "")
	var old_value: int = entry.get("old_value", 0)
	var new_value: int = entry.get("new_value", 0)
	var delta: int = entry.get("delta", 0)
	var reason: String = entry.get("reason", "")
	var timestamp: String = entry.get("timestamp", "")
	
	var entry_panel := PanelContainer.new()
	entry_panel.custom_minimum_size = Vector2(0, 50)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	
	var index_label := Label.new()
	index_label.text = "#%d" % index
	index_label.custom_minimum_size = Vector2(50, 0)
	index_label.add_theme_font_size_override("font_size", 16)
	index_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.94, 1.0))
	
	var resource_label := Label.new()
	resource_label.text = resource
	resource_label.custom_minimum_size = Vector2(80, 0)
	resource_label.add_theme_font_size_override("font_size", 16)
	resource_label.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 1.0))
	
	var change_label := Label.new()
	change_label.text = "%d → %d (%+d)" % [old_value, new_value, delta]
	change_label.custom_minimum_size = Vector2(120, 0)
	change_label.add_theme_font_size_override("font_size", 16)
	
	if delta > 0:
		change_label.add_theme_color_override("font_color", Color(0.31, 0.8, 0.77, 1.0))
	else:
		change_label.add_theme_color_override("font_color", Color(0.91, 0.27, 0.38, 1.0))
	
	var reason_label := Label.new()
	reason_label.text = reason
	reason_label.add_theme_font_size_override("font_size", 14)
	reason_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85, 1.0))
	reason_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var time_label := Label.new()
	time_label.text = timestamp
	time_label.custom_minimum_size = Vector2(150, 0)
	time_label.add_theme_font_size_override("font_size", 12)
	time_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75, 1.0))
	
	hbox.add_child(index_label)
	hbox.add_child(resource_label)
	hbox.add_child(change_label)
	hbox.add_child(reason_label)
	hbox.add_child(time_label)
	
	entry_panel.add_child(hbox)
	
	# Стилизация панели
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.2, 0.6)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(0.37, 0.38, 0.81, 0.3)
	panel_style.corner_radius_top_left = 6
	panel_style.corner_radius_top_right = 6
	panel_style.corner_radius_bottom_right = 6
	panel_style.corner_radius_bottom_left = 6
	entry_panel.add_theme_stylebox_override("panel", panel_style)
	
	log_list.add_child(entry_panel)

func _on_back() -> void:
	EventBus.scene_transition.emit("res://scenes/ui/MainMenu.tscn")

func _on_clear() -> void:
	if tab_container.current_tab == 0:
		ResourceManager.clear_resource_log()
		_load_resource_log()
	else:
		ResourceManager.clear_dialogue_log()
		_load_dialogue_log()

func _on_tab_changed(tab_index: int) -> void:
	if tab_index == 0:
		_load_resource_log()
	else:
		_load_dialogue_log()

func _load_dialogue_log() -> void:
	var dialogue_list: VBoxContainer = $VBoxContainer/TabContainer/DialoguesTab/ScrollContainer2/DialogueList
	for child in dialogue_list.get_children():
		child.queue_free()
	
	var log: Array = ResourceManager.get_dialogue_log()
	
	if log.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Лог диалогов пуст"
		empty_label.add_theme_font_size_override("font_size", 20)
		empty_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.94, 1.0))
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dialogue_list.add_child(empty_label)
		return
	
	# Показываем последние записи
	for i in range(log.size() - 1, -1, -1):
		var entry: Dictionary = log[i] as Dictionary
		_create_dialogue_entry(entry, log.size() - i, dialogue_list)

func _create_dialogue_entry(entry: Dictionary, index: int, parent: VBoxContainer) -> void:
	var character: String = entry.get("character", "")
	var result: String = entry.get("result", "")
	var resource_changes: Dictionary = entry.get("resource_changes", {})
	var timestamp: String = entry.get("timestamp", "")
	
	var entry_panel := PanelContainer.new()
	entry_panel.custom_minimum_size = Vector2(0, 60)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	
	var header_hbox := HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 10)
	
	var index_label := Label.new()
	index_label.text = "#%d" % index
	index_label.custom_minimum_size = Vector2(50, 0)
	index_label.add_theme_font_size_override("font_size", 16)
	index_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.94, 1.0))
	
	var char_label := Label.new()
	char_label.text = character
	char_label.custom_minimum_size = Vector2(100, 0)
	char_label.add_theme_font_size_override("font_size", 16)
	char_label.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 1.0))
	
	var time_label := Label.new()
	time_label.text = timestamp
	time_label.add_theme_font_size_override("font_size", 12)
	time_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75, 1.0))
	
	header_hbox.add_child(index_label)
	header_hbox.add_child(char_label)
	header_hbox.add_child(time_label)
	
	var result_label := Label.new()
	result_label.text = "Результат: " + result
	result_label.add_theme_font_size_override("font_size", 14)
	result_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.94, 1.0))
	
	var changes_label := Label.new()
	var changes_strings: Array = []
	for resource: String in resource_changes:
		var value: int = resource_changes[resource]
		changes_strings.append("%s: %+d" % [resource, value])
	changes_label.text = "Изменения: " + ", ".join(changes_strings)
	changes_label.add_theme_font_size_override("font_size", 13)
	changes_label.add_theme_color_override("font_color", Color(0.31, 0.8, 0.77, 1.0))
	
	vbox.add_child(header_hbox)
	vbox.add_child(result_label)
	vbox.add_child(changes_label)
	
	entry_panel.add_child(vbox)
	
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.2, 0.6)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(0.37, 0.38, 0.81, 0.3)
	panel_style.corner_radius_top_left = 6
	panel_style.corner_radius_top_right = 6
	panel_style.corner_radius_bottom_right = 6
	panel_style.corner_radius_bottom_left = 6
	entry_panel.add_theme_stylebox_override("panel", panel_style)
	
	parent.add_child(entry_panel)
