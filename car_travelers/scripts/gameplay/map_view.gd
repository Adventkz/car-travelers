# res://scripts/gameplay/map_view.gd
extends Node2D

@onready var nodes_container: Node2D = $NodesContainer
@onready var info_label: Label = $InfoPanel/InfoLabel
@onready var background: ColorRect = $Background
@onready var info_panel: PanelContainer = $InfoPanel
@onready var title_panel: Panel = $TitleContainer/TitlePanel
@onready var title_hbox: HBoxContainer = $TitleContainer/TitlePanel/TitleHBox
@onready var title_label: Label = $TitleContainer/TitlePanel/TitleHBox/TitleLabel

var _controller: Node
var _node_buttons: Array[Button] = []

const NODE_BASE_SIZE := Vector2(140, 70)
const NODE_HOVER_SCALE := 1.1
const NODE_COLORS := {
	"city": Color(0.91, 0.27, 0.38, 0.9),      # E94560 - красный
	"forest": Color(0.31, 0.8, 0.77, 0.9),    # 4ECDC4 - бирюзовый
	"road": Color(0.96, 0.65, 0.14, 0.9),     # F5A623 - оранжевый
	"camp": Color(0.37, 0.38, 0.81, 0.9),     # 5E60CE - фиолетовый
	"default": Color(0.23, 0.27, 0.38, 0.9)    # #3B4561
}

func _ready() -> void:
	_controller = Node.new()
	_controller.set_script(load("res://scripts/gameplay/map_controller.gd"))
	add_child(_controller)
	_apply_anime_style()
	_animate_title()
	_build_map_ui()
	# Звуки отключены

func _apply_anime_style() -> void:
	# Стилизация панели информации
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.18, 0.95)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.91, 0.27, 0.38, 0.6)
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_right = 12
	panel_style.corner_radius_bottom_left = 12
	info_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Стилизация текста
	info_label.add_theme_font_size_override("font_size", 14)
	info_label.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 1.0))

func _animate_title() -> void:
	if not title_panel or not title_hbox or not title_label:
		return
	
	# Стилизация панели заголовка в аниме-стиле
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.18, 0.9)
	panel_style.border_width_left = 4
	panel_style.border_width_top = 4
	panel_style.border_width_right = 4
	panel_style.border_width_bottom = 4
	panel_style.border_color = Color(0.91, 0.27, 0.38, 0.8)
	panel_style.shadow_color = Color(0.91, 0.27, 0.38, 0.3)
	panel_style.shadow_offset = Vector2(0, 4)
	panel_style.shadow_size = 8
	panel_style.corner_radius_top_left = 20
	panel_style.corner_radius_top_right = 20
	panel_style.corner_radius_bottom_right = 20
	panel_style.corner_radius_bottom_left = 20
	panel_style.content_margin_left = 40
	panel_style.content_margin_right = 40
	panel_style.content_margin_top = 25
	panel_style.content_margin_bottom = 25
	title_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Стилизация текста заголовка
	title_label.add_theme_font_size_override("font_size", 72)
	title_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	
	# Добавляем отступы между элементами в HBox
	title_hbox.add_theme_constant_override("separation", 20)
	
	# Анимация появления с эффектом
	title_panel.modulate.a = 0.0
	title_panel.scale = Vector2(0.3, 0.3)
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.parallel().tween_property(title_panel, "modulate:a", 1.0, 1.2)
	tween.parallel().tween_property(title_panel, "scale", Vector2(1.0, 1.0), 1.2)
	
	# Плавная градиентная анимация цвета текста
	tween.tween_interval(0.2)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_loops()
	tween.tween_property(title_label, "modulate", Color(0.91, 0.27, 0.38, 1.0), 1.0)
	tween.tween_property(title_label, "modulate", Color(1.0, 0.5, 0.6, 1.0), 1.0)
	tween.tween_property(title_label, "modulate", Color(1.0, 0.7, 0.8, 1.0), 1.0)
	tween.tween_property(title_label, "modulate", Color(1.0, 0.5, 0.6, 1.0), 1.0)

func _build_map_ui() -> void:
	var file := FileAccess.open("res://data/routes/chapter_01.json", FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return
	file.close()

	var nodes: Array = (json.data as Dictionary).get("nodes", [])
	var current_node_id := GameState.current_node_id
	
	# Определяем доступные узлы
	var available_nodes := _get_available_nodes(current_node_id, nodes)
	
	for node_data in nodes:
		var pos: Array = node_data.get("position", [0, 0])
		var node_type: String = node_data.get("type", "default")
		var node_id: String = node_data.get("node_id", "")
		
		# Проверяем доступен ли узел
		var is_available := available_nodes.has(node_id)
		var is_current := node_id == current_node_id
		var is_visited := _is_node_visited(node_id)
		
		# Создаем контейнер для узла карты
		var node_container := Control.new()
		node_container.position = Vector2(pos[0], pos[1])
		node_container.custom_minimum_size = NODE_BASE_SIZE
		
		# Фон узла с аниме-стилем и скруглёнными углами
		var node_bg := PanelContainer.new()
		var bg_color = NODE_COLORS.get(node_type, NODE_COLORS.default)
		
		# Если узел недоступен и не посещён, делаем его серым
		if not is_available and not is_visited:
			bg_color = Color(0.3, 0.3, 0.35, 0.6)
		elif is_visited and not is_current:
			bg_color = bg_color.lerp(Color(0.5, 0.5, 0.5, 1.0), 0.3)
		
		var bg_style := StyleBoxFlat.new()
		bg_style.bg_color = bg_color
		bg_style.border_width_left = 3
		bg_style.border_width_top = 3
		bg_style.border_width_right = 3
		bg_style.border_width_bottom = 3
		bg_style.border_color = bg_color.lightened(0.2)
		bg_style.corner_radius_top_left = 15
		bg_style.corner_radius_top_right = 15
		bg_style.corner_radius_bottom_right = 15
		bg_style.corner_radius_bottom_left = 15
		node_bg.add_theme_stylebox_override("panel", bg_style)
		node_bg.custom_minimum_size = NODE_BASE_SIZE
		node_container.add_child(node_bg)
		
		# Внутренний контейнер для иконки и текста
		var inner_hbox := HBoxContainer.new()
		inner_hbox.add_theme_constant_override("separation", 8)
		node_bg.add_child(inner_hbox)
		
		# Иконка узла
		var icon_label := Label.new()
		var icon_char := _get_node_icon(node_type)
		icon_label.text = icon_char
		icon_label.add_theme_font_size_override("font_size", 28)
		icon_label.custom_minimum_size = Vector2(40, 0)
		if is_available or is_visited:
			icon_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
		else:
			icon_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
		inner_hbox.add_child(icon_label)
		
		# Кнопка узла с текстом
		var btn := Button.new()
		btn.text = node_data.get("display_name", "")
		btn.custom_minimum_size = Vector2(90, 0)
		btn.add_theme_font_size_override("font_size", 14)
		
		# Цвет текста
		if is_available or is_visited:
			btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
		else:
			btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
		
		# Стилизация кнопки - прозрачная
		var btn_style := StyleBoxFlat.new()
		btn_style.bg_color = Color(0, 0, 0, 0)
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_stylebox_override("hover", btn_style)
		btn.add_theme_stylebox_override("pressed", btn_style)
		
		# Кнопка активна только для доступных узлов
		btn.disabled = not is_available
		
		btn.pressed.connect(_on_node_selected.bind(node_id, node_data))
		
		# Hover эффект только для доступных узлов
		if is_available:
			btn.mouse_entered.connect(_on_node_hover.bind(node_container, true, node_data))
			btn.mouse_exited.connect(_on_node_hover.bind(node_container, false, node_data))
		
		inner_hbox.add_child(btn)
		nodes_container.add_child(node_container)
		_node_buttons.append(btn)

func _get_available_nodes(current_node_id: String, nodes: Array) -> Array[String]:
	var available: Array[String] = []
	
	# Находим текущий узел
	var current_node_data: Dictionary
	for node in nodes:
		if node.get("node_id", "") == current_node_id:
			current_node_data = node
			break
	
	if current_node_data.is_empty():
		# Если текущий узел не найден, возвращаем стартовый
		return ["node_start"]
	
	# Добавляем текущий узел
	available.append(current_node_id)
	
	# Добавляем связанные узлы
	var connected: Array = current_node_data.get("connected_nodes", [])
	for node_id in connected:
		available.append(node_id as String)
	
	return available

func _get_node_icon(node_type: String) -> String:
	match node_type:
		"city": return "🏙️"
		"forest": return "🌲"
		"road": return "🛣️"
		"camp": return "⛺"
		_: return "📍"

func _is_node_visited(node_id: String) -> bool:
	# Простой способ - проверяем есть ли узел в истории посещений
	# Для упрощения считаем что все узлы до текущего посещены
	return false

func _on_node_hover(container: Control, is_hovering: bool, node_data: Dictionary) -> void:
	var target_scale: float = NODE_HOVER_SCALE if is_hovering else 1.0
	var tween: Tween = container.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(container, "scale", Vector2(target_scale, target_scale), 0.2)
	var connected: Array = node_data.get("connected_nodes", [])
	if not connected.is_empty() and GameState.current_node_id in connected:
		# Можно ехать
		var terrain: String = node_data.get("terrain", "asphalt")
		var dist: float = float(node_data.get("distance_km", 0))
		var cost: int = ResourceManager.calculate_fuel_cost(dist, terrain)
		var node_id: String = node_data.get("node_id", "")
		info_label.text = "%s — %d км (%s), топлива: -%d" % [
			node_data.get("display_name", node_id), int(dist), terrain, cost
		]
		_controller.select_node(node_id)
		SaveManager.save_game()

func _on_node_selected(node_id: String, node_data: Dictionary) -> void:
	var connected: Array = node_data.get("connected_nodes", [])
	if not connected.is_empty() and GameState.current_node_id in connected:
		_show_travel_confirmation(node_id, node_data)

func _show_travel_confirmation(node_id: String, node_data: Dictionary) -> void:
	var terrain: String = node_data.get("terrain", "asphalt")
	var dist: float = float(node_data.get("distance_km", 0))
	var fuel_cost: int = ResourceManager.calculate_fuel_cost(dist, terrain)
	var stress_cost: int = ResourceManager.calculate_stress_delta()
	
	var confirmation_text := "Путешествие в %s\n\n" % node_data.get("display_name", node_id)
	confirmation_text += "Расстояние: %d км\n" % int(dist)
	confirmation_text += "Местность: %s\n\n" % terrain
	confirmation_text += "Затраты:\n"
	confirmation_text += "  Топливо: -%d\n" % fuel_cost
	confirmation_text += "  Стресс: +%d\n\n" % stress_cost
	confirmation_text += "Продолжить?"
	
	var dialogue_view = get_node_or_null("/root/DialogueView")
	if dialogue_view and dialogue_view.has_method("show_dialogue"):
		var lines := [
			{
				"speaker": "Навигатор",
				"text": confirmation_text,
				"portrait": "",
				"choices": [
					{
						"text": "Ехать",
						"mutations": [],
						"jump": "travel"
					},
					{
						"text": "Назад",
						"mutations": [],
						"jump": "end"
					},
					{
						"text": "Спать",
						"mutations": [],
						"jump": "camp"
					}
				]
			}
		]
		
		dialogue_view.dialogue_finished.connect(_on_travel_dialogue_finished.bind(node_id, node_data))
		dialogue_view.show_dialogue("travel_confirmation", lines)

func _on_travel_dialogue_finished(node_id: String, node_data: Dictionary, dialogue_id: String) -> void:
	var dialogue_view = get_node_or_null("/root/DialogueView")
	if dialogue_view:
		dialogue_view.dialogue_finished.disconnect(_on_travel_dialogue_finished.bind(node_id, node_data))
	
	# Проверяем какой выбор был сделан через флаг в GameState
	if GameState.get_flag("travel_confirmed"):
		GameState.set_flag("travel_confirmed", false)
		_controller.select_node(node_id)
		SaveManager.save_game()
	elif GameState.get_flag("go_to_camp"):
		GameState.set_flag("go_to_camp", false)
		GameState.set_phase(GameState.Phase.CAMP)
		EventBus.scene_transition.emit("res://scenes/gameplay/CampScene.tscn")

func _save_game_result(won: bool) -> void:
	GameState.set_game_over(won)
	
	var result_data := {
		"date": Time.get_datetime_string_from_system(),
		"won": won,
		"day": GameState.day_count,
		"resources": ResourceManager.get_all()
	}
	
	var history_path := "user://saves/game_history.json"
	var dir := DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")
	
	var file := FileAccess.open(history_path, FileAccess.READ)
	var history := []
	if file:
		var json := JSON.new()
		var err := json.parse(file.get_as_text())
		if err == OK:
			history = json.data as Array
		file.close()
	
	history.append(result_data)
	
	# Ограничиваем историю до 10 записей
	if history.size() > 10:
		history = history.slice(history.size() - 10, history.size())
	
	var save_file := FileAccess.open(history_path, FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(history, "\t"))
		save_file.close()
