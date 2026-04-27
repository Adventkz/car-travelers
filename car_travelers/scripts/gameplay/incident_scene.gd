# res://scripts/gameplay/incident_scene.gd
extends Control

@onready var title_label: Label = $CenterContainer/TitleLabel
@onready var desc_label: Label = $CenterContainer/DescriptionLabel
@onready var choices_container: VBoxContainer = $CenterContainer/ChoicesContainer

var _controller: Node

func _ready() -> void:
	_apply_anime_style()
	
	_controller = Node.new()
	_controller.set_script(load("res://scripts/gameplay/incident_controller.gd"))
	add_child(_controller)
	_controller.incident_choices_ready.connect(_populate_ui)
	_controller.start_random()

func _apply_anime_style() -> void:
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", Color(0.91, 0.27, 0.38, 1.0))
	
	desc_label.add_theme_font_size_override("font_size", 18)
	desc_label.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 1.0))

func _populate_ui(incident: Dictionary) -> void:
	title_label.text = incident.get("title", "")
	desc_label.text = incident.get("description", "")

	for child in choices_container.get_children():
		child.queue_free()

	var choices: Array = incident.get("choices", [])
	for i in choices.size():
		var btn := Button.new()
		btn.text = choices[i].get("text", "Выбор %d" % i)
		btn.pressed.connect(_controller.resolve.bind(i))
		_style_choice_button(btn)
		choices_container.add_child(btn)

func _style_choice_button(btn: Button) -> void:
	btn.custom_minimum_size = Vector2(0, 45)
	
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
	
	btn.add_theme_font_size_override("font_size", 16)
	btn.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 1.0))
