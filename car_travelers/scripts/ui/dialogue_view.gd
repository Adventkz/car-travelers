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
	hide()
	next_btn.pressed.connect(_advance)

# --- Публичный API ---

func show_dialogue(dialogue_id: String, lines: Array) -> void:
	_dialogue_id = dialogue_id
	_lines = lines
	_current_line = 0
	show()
	_show_line()

func _show_line() -> void:
	if _current_line >= _lines.size():
		_finish()
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
		portrait_path = _get_portrait_path(speaker)

	if portrait_path != "" and ResourceLoader.exists(portrait_path):
		portrait.texture = load(portrait_path)
	else:
		portrait.texture = null

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
		if not requires.is_empty():
			var req_trait: String = requires.get("trait", "")
			var req_char: String = requires.get("char", "")
			var req_min: int = requires.get("min", 0)
			if req_char != "" and req_trait != "":
				btn.disabled = not TraitSystem.check(req_char, req_trait, req_min)
		btn.pressed.connect(_on_choice.bind(i, c))
		choices_container.add_child(btn)

func _on_choice(idx: int, choice: Dictionary) -> void:
	var mutations: Array = choice.get("mutations", [])
	for m in mutations:
		_apply_mutation(m as Dictionary)
	_clear_choices()
	_current_line += 1
	var jump: String = choice.get("jump", "")
	if jump != "":
		_jump_to(jump)
		return
	_show_line()

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
