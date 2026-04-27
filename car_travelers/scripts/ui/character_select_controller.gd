# res://scripts/ui/character_select_controller.gd
extends Control

signal family_selected(family_id: String)

@onready var family_a_button := $VBoxContainer/FamilyAButton
@onready var family_b_button := $VBoxContainer/FamilyBButton
@onready var family_a_preview := $VBoxContainer/FamilyAPreview
@onready var family_b_preview := $VBoxContainer/FamilyBPreview
@onready var start_button := $VBoxContainer/StartButton
@onready var back_button := $VBoxContainer/BackButton
@onready var title_label := $VBoxContainer/Title
@onready var background := $Background

var _selected_family: String = ""

const HOVER_SCALE := 1.05
const NORMAL_SCALE := 1.0

func _ready() -> void:
	_apply_anime_style()
	
	family_a_button.pressed.connect(_on_family_a_selected)
	family_b_button.pressed.connect(_on_family_b_selected)
	start_button.pressed.connect(_on_start_game)
	back_button.pressed.connect(_on_back_to_menu)
	
	# Hover эффекты
	_setup_button_hover(family_a_button)
	_setup_button_hover(family_b_button)
	_setup_button_hover(start_button)
	_setup_button_hover(back_button)
	
	start_button.disabled = true
	_update_previews()

func _apply_anime_style() -> void:
	# Фон с градиентом
	background.set_script(load("res://assets/visuals/backgrounds/main_menu_bg.gd"))
	
	# Заголовок
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color(0.91, 0.27, 0.38, 1.0))
	
	# Стилизация кнопок семей
	_style_family_button(family_a_button, Color(0.91, 0.27, 0.38, 0.9))
	_style_family_button(family_b_button, Color(0.31, 0.8, 0.77, 0.9))
	
	# Стилизация кнопок действий
	_style_action_button(start_button)
	_style_action_button(back_button)
	
	# Стилизация превью
	_style_preview(family_a_preview)
	_style_preview(family_b_preview)

func _style_family_button(btn: Button, color: Color) -> void:
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

func _style_action_button(btn: Button) -> void:
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

func _style_preview(label: Label) -> void:
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.94, 1.0))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

func _setup_button_hover(btn: Button) -> void:
	btn.mouse_entered.connect(func(): _animate_hover(btn, true))
	btn.mouse_exited.connect(func(): _animate_hover(btn, false))

func _animate_hover(btn: Button, is_hovering: bool) -> void:
	var target_scale = HOVER_SCALE if is_hovering else NORMAL_SCALE
	var tween = btn.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(btn, "scale", Vector2(target_scale, target_scale), 0.2)

func _on_family_a_selected() -> void:
	_selected_family = "family_a"
	start_button.disabled = false
	_update_selection()

func _on_family_b_selected() -> void:
	_selected_family = "family_b"
	start_button.disabled = false
	_update_selection()

func _on_start_game() -> void:
	if _selected_family.is_empty():
		return
	
	GameState.active_family = _selected_family
	SaveManager.save_game()
	family_selected.emit(_selected_family)
	
	# Переход к карте
	GameState.set_phase(GameState.Phase.MAP)
	EventBus.scene_transition.emit("res://scenes/gameplay/MapView.tscn")

func _on_back_to_menu() -> void:
	EventBus.scene_transition.emit("res://scenes/ui/MainMenu.tscn")

func _update_selection() -> void:
	if _selected_family == "family_a":
		family_a_button.modulate = Color.WHITE
		family_b_button.modulate = Color(0.5, 0.5, 0.5, 0.7)
	elif _selected_family == "family_b":
		family_a_button.modulate = Color(0.5, 0.5, 0.5, 0.7)
		family_b_button.modulate = Color.WHITE
	else:
		family_a_button.modulate = Color.WHITE
		family_b_button.modulate = Color.WHITE

func _update_previews() -> void:
	# Показываем превью семей
	# Family A: Сарын, Асель, Данияр, Зарина, Мирас, Гульнара
	var family_a_chars = ["saryn", "asel", "daniyar", "zarina", "miras", "gulnara"]
	# Family B: Руслан, Дина, Тимур, + другие
	var family_b_chars = ["ruslan", "dina", "timur", "azamat", "assel", "maksat"]
	
	# TODO: Загрузить и отобразить портреты
	# Для упрощения используем текст
	family_a_preview.text = "Семья А:\nСарын, Асель, Данияр, Зарина, Мирас, Гульнара"
	family_b_preview.text = "Семья Б:\nРуслан, Дина, Тимур, Азамат, Ассель, Максат"
