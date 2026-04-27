# res://scripts/ui/family_stats.gd
extends Control

var _previous_scene: String = ""

@onready var title_label: Label = $VBoxContainer/Title
@onready var family_list: VBoxContainer = $VBoxContainer/ScrollContainer/FamilyList
@onready var back_button: Button = $VBoxContainer/BackButton

func _ready() -> void:
	_previous_scene = GameState.get_previous_scene()
	_apply_anime_style()
	_load_family_stats()
	
	back_button.pressed.connect(_on_back)

func _apply_anime_style() -> void:
	title_label.add_theme_font_size_override("font_size", 28)
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

func _load_family_stats() -> void:
	var family_id := GameState.active_family
	
	# Загружаем данные персонажей семьи
	var char_dir := DirAccess.open("res://data/characters/")
	if not char_dir:
		return
	
	char_dir.list_dir_begin()
	var file_name := char_dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".json"):
			var char_path := "res://data/characters/" + file_name
			var file := FileAccess.open(char_path, FileAccess.READ)
			if file:
				var json := JSON.new()
				if json.parse(file.get_as_text()) == OK:
					var char_data: Dictionary = json.data as Dictionary
					if char_data.get("family_id") == family_id:
						_create_character_entry(char_data)
				file.close()
		file_name = char_dir.get_next()
	
	char_dir.list_dir_end()

func _create_character_entry(char_data: Dictionary) -> void:
	var char_id: String = char_data.get("char_id", "")
	var display_name: String = char_data.get("display_name", char_id)
	var age: int = char_data.get("age", 0)
	var role: String = char_data.get("role", "")
	var portrait_path: String = char_data.get("portrait_path", "")
	var traits: Dictionary = char_data.get("traits", {})
	
	var entry := PanelContainer.new()
	entry.custom_minimum_size = Vector2(0, 120)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 15)
	
	# Портрет
	var portrait := TextureRect.new()
	portrait.custom_minimum_size = Vector2(100, 100)
	if not portrait_path.is_empty():
		var texture = load(portrait_path)
		if texture:
			portrait.texture = texture
	
	# Информация о персонаже
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	
	var name_label := Label.new()
	name_label.text = "%s (%d лет)" % [display_name, age]
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 1.0))
	
	var role_label := Label.new()
	role_label.text = "Роль: %s" % role
	role_label.add_theme_font_size_override("font_size", 16)
	role_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.94, 1.0))
	
	var traits_label := Label.new()
	var trait_strings: Array = []
	for trait_name: String in traits:
		var value: int = traits[trait_name]
		if value >= 2:
			trait_strings.append("%s: %d" % [trait_name, value])
	traits_label.text = "Черты: " + ", ".join(trait_strings)
	traits_label.add_theme_font_size_override("font_size", 14)
	traits_label.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85, 1.0))
	
	# Кнопка диалога
	var dialogue_btn := Button.new()
	dialogue_btn.text = "Разговор"
	dialogue_btn.custom_minimum_size = Vector2(100, 40)
	dialogue_btn.pressed.connect(func(): _on_character_dialogue(char_id))
	_style_dialogue_button(dialogue_btn)
	
	vbox.add_child(name_label)
	vbox.add_child(role_label)
	vbox.add_child(traits_label)
	
	hbox.add_child(portrait)
	hbox.add_child(vbox)
	hbox.add_child(dialogue_btn)
	
	entry.add_child(hbox)
	
	# Стилизация панели
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.37, 0.38, 0.81, 0.5)
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_right = 10
	panel_style.corner_radius_bottom_left = 10
	entry.add_theme_stylebox_override("panel", panel_style)
	
	family_list.add_child(entry)

func _style_dialogue_button(btn: Button) -> void:
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.31, 0.8, 0.77, 0.9)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = Color(0.31, 0.8, 0.77, 1.0)
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_right = 8
	normal_style.corner_radius_bottom_left = 8
	btn.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style := normal_style.duplicate()
	hover_style.bg_color = Color(0.4, 0.9, 0.87, 0.95)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))

func _on_character_dialogue(char_id: String) -> void:
	# Открываем диалог с персонажем через DialogueView
	var dialogue_view = get_node_or_null("/root/DialogueView")
	if dialogue_view and dialogue_view.has_method("show_dialogue"):
		# Вариативные фразы для гриндинга
		var phrases: Array = [
			"Привет! Чем могу помочь?",
			"Что-то нужно?",
			"Я тут кое-что нашёл...",
			"Слушай, у меня есть идея",
			"Хочешь поговорить?"
		]
		var random_phrase: String = phrases[randi() % phrases.size()]
		
		# Вариативные награды
		var reward_options: Array = [
			{"type": "food", "delta": randi_range(3, 8)},
			{"type": "fuel", "delta": randi_range(3, 8)},
			{"type": "stress", "delta": -randi_range(3, 7)}
		]
		var random_reward: Dictionary = reward_options[randi() % reward_options.size()]
		
		var lines := [
			{
				"speaker": char_id.capitalize(),
				"text": random_phrase,
				"portrait": "",
				"choices": [
					{
						"text": "Где можно найти еду?",
						"mutations": [{"type": "food", "delta": randi_range(3, 8)}],
						"jump": "end"
					},
					{
						"text": "Где топливо?",
						"mutations": [{"type": "fuel", "delta": randi_range(3, 8)}],
						"jump": "end"
					},
					{
						"text": "Как дела?",
						"mutations": [random_reward],
						"jump": "end"
					},
					{
						"text": "Ничего",
						"jump": "end"
					}
				]
			}
		]
		dialogue_view.dialogue_finished.connect(_on_family_dialogue_finished)
		dialogue_view.show_dialogue("family_chat_" + char_id, lines)
	else:
		print("DialogueView не найден")

func _on_family_dialogue_finished(dialogue_id: String) -> void:
	var dialogue_view = get_node_or_null("/root/DialogueView")
	if dialogue_view:
		dialogue_view.dialogue_finished.disconnect(_on_family_dialogue_finished)

func _log_dialogue(char_id: String, result: String, resource_changes: Dictionary) -> void:
	var log_entry := {
		"timestamp": Time.get_datetime_string_from_system(false),
		"type": "dialogue",
		"character": char_id,
		"result": result,
		"resource_changes": resource_changes
	}
	ResourceManager.add_dialogue_log(log_entry)

func _on_back() -> void:
	if not _previous_scene.is_empty():
		GameState.set_previous_scene("res://scenes/ui/FamilyStats.tscn")
		EventBus.scene_transition.emit(_previous_scene)
	else:
		EventBus.scene_transition.emit("res://scenes/ui/MainMenu.tscn")
