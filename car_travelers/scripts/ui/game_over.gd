# res://scripts/ui/game_over.gd
extends Control

@onready var title_label: Label = $VBoxContainer/Title
@onready var reason_label: Label = $VBoxContainer/ReasonLabel
@onready var stats_label: Label = $VBoxContainer/StatsLabel
@onready var menu_button: Button = $VBoxContainer/MenuButton

var _game_over_reason := ""

func _ready() -> void:
	_apply_anime_style()
	_set_content()
	
	menu_button.pressed.connect(_on_menu)

func set_game_over_reason(reason: String) -> void:
	_game_over_reason = reason
	if reason_label:
		reason_label.text = reason

func _set_content() -> void:
	if not _game_over_reason.is_empty():
		reason_label.text = _game_over_reason
	
	stats_label.text = "Дней выжито: %d" % GameState.day_count

func _apply_anime_style() -> void:
	title_label.add_theme_font_size_override("font_size", 42)
	title_label.add_theme_color_override("font_color", Color(0.91, 0.27, 0.38, 1.0))
	
	reason_label.add_theme_font_size_override("font_size", 20)
	reason_label.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 1.0))
	
	stats_label.add_theme_font_size_override("font_size", 18)
	stats_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.94, 1.0))
	
	_style_menu_button(menu_button)

func _style_menu_button(btn: Button) -> void:
	btn.custom_minimum_size = Vector2(0, 60)
	
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.91, 0.27, 0.38, 0.9)
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
	hover_style.bg_color = Color(0.95, 0.35, 0.45, 0.95)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))

func _on_menu() -> void:
	EventBus.scene_transition.emit("res://scenes/ui/MainMenu.tscn")
