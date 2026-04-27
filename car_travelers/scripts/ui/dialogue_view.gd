# res://scripts/ui/dialogue_view.gd
# Универсальный оверлей для диалогов (standalone, без плагина)
extends CanvasLayer

signal dialogue_finished(dialogue_id: String)

@onready var backdrop: ColorRect = $Backdrop
@onready var portrait: TextureRect = $Portrait
@onready var name_label: Label = $NameLabel
@onready var text_label: RichTextLabel = $TextLabel
@onready var choices_container: VBoxContainer = $ChoicesContainer
@onready var next_btn: Button = $NextButton

var _lines: Array = []
var _current_line: int = 0
var _dialogue_id: String = ""
var _waiting_choice: bool = false

func _ready() -> void:
	_apply_anime_style()
	hide()
	next_btn.pressed.connect(_advance)

func _apply_anime_style() -> void:
	name_label.add_theme_font_size_override("font_size", 24)
	name_label.add_theme_color_override("font_color", Color(0.91, 0.27, 0.38, 1.0))
	
	text_label.add_theme_font_size_override("normal_font_size", 18)
	
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0.23, 0.27, 0.38, 0.9)
	btn_style.border_width_left = 2
	btn_style.border_width_top = 2
	btn_style.border_width_right = 2
	btn_style.border_width_bottom = 2
	btn_style.border_color = Color(0.91, 0.27, 0.38, 0.6)
	btn_style.corner_radius_top_left = 8
	btn_style.corner_radius_top_right = 8
	btn_style.corner_radius_bottom_right = 8
	btn_style.corner_radius_bottom_left = 8
	next_btn.add_theme_stylebox_override("normal", btn_style)
	
	var hover_style := btn_style.duplicate()
	hover_style.bg_color = Color(0.3, 0.35, 0.5, 0.95)
	next_btn.add_theme_stylebox_override("hover", hover_style)
	
	next_btn.add_theme_font_size_override("font_size", 20)
	next_btn.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 1.0))

# --- Публичный API ---

func show_dialogue(dialogue_id: String, lines: Array) -> void:
	_dialogue_id = dialogue_id
	_lines = lines
	_current_line = 0
	show()
	_show_line()

func _show_line() -> void:
	if _current_line >= _lines.size():
		dialogue_finished.emit(_dialogue_id)
		hide()
		return
	
	var line: Dictionary = _lines[_current_line]
	var speaker: String = line.get("speaker", "")
	var text: String = line.get("text", "")
	var portrait_path: String = line.get("portrait", "")
	var choices: Array = line.get("choices", [])

	name_label.text = speaker
	text_label.text = text

	# Если портрет не указан явно, пробуем загрузить по имени говорящего
	if portrait_path.is_empty() and not speaker.is_empty():
		# Маппинг русских имен на ID персонажей
		var name_to_id := {
			"Сарын": "saryn",
			"Данияр": "daniyar",
			"Алия": "aliya",
			"Альмаз": "almaz",
			"Арман": "arman",
			"Асель": "asel",
			"Ассель": "assel",
			"Азамат": "azamat",
			"Болат": "bolat",
			"Дархан": "darkhan",
			"Даурен": "dauren",
			"Дина": "dina",
			"Ерлан": "erlan",
			"Ержан": "erzhan",
			"Гульнара": "gulnara",
			"Гульжан": "gulzhan",
			"Камила": "kamila",
			"Максат": "maksat",
			"Меруерт": "meruert",
			"Мирас": "miras",
			"Нурлы": "nurly",
			"Руслан": "ruslan",
			"Санжар": "sanzhar",
			"Сауле": "saule",
			"Тимур": "timur",
			"Зарина": "zarina",
			"Айнур": "ainur",
			"Айнура": "ainura"
		}
		
		var char_id: String = name_to_id.get(speaker, speaker.to_lower())
		var portrait_path_candidate := "res://assets/visuals/characters/%s/portrait_neutral.png" % char_id
		
		if FileAccess.file_exists(portrait_path_candidate):
			portrait_path = portrait_path_candidate
	
	if not portrait_path.is_empty():
		var texture = load(portrait_path)
		if texture:
			portrait.texture = texture
			portrait.show()
		else:
			portrait.hide()
	else:
		portrait.hide()

	_clear_choices()

	if choices.is_empty():
		_waiting_choice = false
		next_btn.show()
	else:
		_waiting_choice = true
		next_btn.hide()
		_build_choices(choices)

	# Мутации
	var mutations: Array = line.get("mutations", [])
	for m in mutations:
		_apply_mutation(m as Dictionary)

func _build_choices(choices: Array) -> void:
	for i in choices.size():
		var c: Dictionary = choices[i] as Dictionary
		var requires: Dictionary = c.get("requires", {})
		var btn := Button.new()
		btn.text = c.get("text", "")
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD
		_style_choice_button(btn)
		if not requires.is_empty():
			var req_trait: String = requires.get("trait", "")
			var req_char: String = requires.get("char", "")
			var req_min: int = requires.get("min", 0)
			if req_char != "" and req_trait != "":
				btn.disabled = not TraitSystem.check(req_char, req_trait, req_min)
		btn.pressed.connect(_on_choice.bind(i, c))
		choices_container.add_child(btn)

func _style_choice_button(btn: Button) -> void:
	btn.custom_minimum_size = Vector2(0, 40)
	
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.23, 0.27, 0.38, 0.9)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = Color(0.31, 0.8, 0.77, 0.6)
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_right = 8
	normal_style.corner_radius_bottom_left = 8
	btn.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style := normal_style.duplicate()
	hover_style.bg_color = Color(0.3, 0.35, 0.5, 0.95)
	hover_style.border_color = Color(0.31, 0.8, 0.77, 0.8)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	var disabled_style := normal_style.duplicate()
	disabled_style.bg_color = Color(0.15, 0.15, 0.2, 0.7)
	disabled_style.border_color = Color(0.3, 0.3, 0.3, 0.4)
	btn.add_theme_stylebox_override("disabled", disabled_style)
	
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 1.0))

func _on_choice(idx: int, choice: Dictionary) -> void:
	var mutations: Array = choice.get("mutations", [])
	var jump: String = choice.get("jump", "")
	
	# Специальные действия для диалога путешествия
	if jump == "travel":
		GameState.set_flag("travel_confirmed", true)
		dialogue_finished.emit(_dialogue_id)
		hide()
		return
	elif jump == "camp":
		GameState.set_flag("go_to_camp", true)
		dialogue_finished.emit(_dialogue_id)
		hide()
		return
	
	# Специальное действие для стартовой локации - выбор направления
	if _dialogue_id == "start_location" and jump != "" and jump != "end":
		# Сохраняем выбранное направление через EventBus для map_view
		EventBus.emit_signal("start_direction_selected", jump)
		dialogue_finished.emit(_dialogue_id)
		hide()
		return
	
	# Проверяем на штраф за неверный ответ (один или несколько)
	var penalty: Dictionary = choice.get("penalty", {})
	var penalties: Array = choice.get("penalties", [])
	
	if not penalty.is_empty():
		_apply_penalty(penalty)
	
	for p in penalties:
		_apply_penalty(p as Dictionary)
	
	for m in mutations:
		_apply_mutation(m as Dictionary)
	_clear_choices()
	
	if jump == "end":
		dialogue_finished.emit(_dialogue_id)
		hide()
		return
	elif jump != "":
		_jump_to(jump)
		return
	_current_line += 1
	_show_line()

func _apply_penalty(penalty: Dictionary) -> void:
	var resource_type: String = penalty.get("resource", "")
	var amount: int = penalty.get("amount", 0)
	var reason: String = penalty.get("reason", "Штраф")
	
	if not resource_type.is_empty() and amount != 0:
		ResourceManager.modify(resource_type, -amount)
		print("Штраф: %s %d - %s" % [resource_type, amount, reason])

func _advance() -> void:
	if _waiting_choice:
		return
	_current_line += 1
	_show_line()

func _jump_to(label: String) -> void:
	for i in _lines.size():
		var line: Dictionary = _lines[i] as Dictionary
		if line.get("label", "") == label:
			_current_line = i
			_show_line()
			return
	push_warning("dialogue_view: label not found: %s" % label)
	_finish()

func _apply_mutation(m: Dictionary) -> void:
	var fn: String = m.get("fn", "")
	match fn:
		"TraitSystem.reinforce":
			TraitSystem.reinforce(m.get("char_id", ""), m.get("trait_id", ""), int(m.get("delta", 0)))
		"ResourceManager.modify":
			ResourceManager.modify(m.get("type", ""), int(m.get("delta", 0)))
		"GameState.set_flag":
			GameState.set_flag(m.get("key", ""), bool(m.get("value", true)))

func _get_portrait_path(speaker: String) -> String:
	# Преобразуем имя в lowercase и убираем пробелы
	var char_id := speaker.to_lower().replace(" ", "_")
	return "res://assets/visuals/characters/" + char_id + "/portrait_neutral.png"

func _clear_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()

func _finish() -> void:
	hide()
	EventBus.dialogue_ended.emit(_dialogue_id)
	dialogue_finished.emit(_dialogue_id)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept") and not _waiting_choice:
		_advance()
		get_viewport().set_input_as_handled()
