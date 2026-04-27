# res://scripts/gameplay/camp_scene.gd
extends Control

@onready var title_label: Label = $VBox/Title
@onready var day_label: Label = $VBox/DayLabel
@onready var dialogue_btn: Button = $VBox/DialogueButton
@onready var sleep_btn: Button = $VBox/SleepButton

var _controller: Node
var _dialogue_completed := false

func _ready() -> void:
	_apply_anime_style()
	
	_controller = Node.new()
	_controller.set_script(load("res://scripts/gameplay/camp_controller.gd"))
	add_child(_controller)

	day_label.text = "День %d" % GameState.day_count
	
	# Кнопка сна недоступна пока не проведён диалог
	sleep_btn.disabled = true
	
	dialogue_btn.pressed.connect(_on_dialogue)
	sleep_btn.pressed.connect(_on_sleep)

func _on_dialogue() -> void:
	_controller.start_camp_dialogue("camp_day_%02d" % GameState.day_count)
	# После начала диалога скрываем кнопку диалога
	dialogue_btn.hide()

func on_dialogue_finished() -> void:
	_dialogue_completed = true
	# После диалога делаем кнопку сна доступной
	sleep_btn.disabled = false
	sleep_btn.text = "СПАТЬ"
	# Показываем кнопку диалога снова для возможности гриндинга
	dialogue_btn.show()
	dialogue_btn.text = "Разговор снова"

func _on_sleep() -> void:
	_controller.end_camp()

func _apply_anime_style() -> void:
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color(0.91, 0.27, 0.38, 1.0))
	
	day_label.add_theme_font_size_override("font_size", 20)
	day_label.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 1.0))
	
	_style_camp_button(dialogue_btn, Color(0.31, 0.8, 0.77, 0.9))
	_style_camp_button(sleep_btn, Color(0.96, 0.65, 0.14, 0.9))

func _style_camp_button(btn: Button, color: Color) -> void:
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
