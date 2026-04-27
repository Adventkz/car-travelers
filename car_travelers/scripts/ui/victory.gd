# res://scripts/ui/victory.gd
extends Control

@onready var title_label: Label = $VBoxContainer/Title
@onready var subtitle_label: Label = $VBoxContainer/Subtitle
@onready var days_label: Label = $VBoxContainer/StatsContainer/DaysLabel
@onready var family_label: Label = $VBoxContainer/StatsContainer/FamilyLabel
@onready var resources_label: Label = $VBoxContainer/StatsContainer/ResourcesLabel
@onready var traits_label: Label = $VBoxContainer/StatsContainer/TraitsLabel
@onready var menu_button: Button = $VBoxContainer/MenuButton

func _ready() -> void:
	_apply_anime_style()
	_set_content()
	
	menu_button.pressed.connect(_on_menu)

func _set_content() -> void:
	days_label.text = "Дней в пути: %d" % GameState.day_count
	
	var family_name = "Семья А (Сарын)" if GameState.active_family == "family_a" else "Семья Б (Руслан)"
	family_label.text = "Семья: %s" % family_name
	
	resources_label.text = "Остаток ресурсов:\n  Топливо: %d\n  Еда: %d\n  Стресс: %d\n  Авто: %d" % [
		ResourceManager.fuel, ResourceManager.food, ResourceManager.stress, ResourceManager.vehicle_hp
	]
	
	# Показываем доминантные трейты
	var traits_text = "Отношения: "
	var family_chars = ["saryn", "asel", "daniyar", "zarina", "miras", "gulnara"] if GameState.active_family == "family_a" else ["ruslan", "dina", "timur", "azamat", "assel", "maksat"]
	var trait_count = 0
	for char_id in family_chars:
		var dominant = TraitSystem.get_dominant(char_id)
		if not dominant.is_empty():
			traits_text += char_id + " (" + dominant + "), "
			trait_count += 1
	
	if trait_count == 0:
		traits_text = "Отношения: Нет данных"
	
	traits_label.text = traits_text

func _apply_anime_style() -> void:
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.add_theme_color_override("font_color", Color(0.31, 0.8, 0.77, 1.0))
	
	subtitle_label.add_theme_font_size_override("font_size", 24)
	subtitle_label.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92, 1.0))
	
	days_label.add_theme_font_size_override("font_size", 18)
	days_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.94, 1.0))
	
	family_label.add_theme_font_size_override("font_size", 18)
	family_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.94, 1.0))
	
	resources_label.add_theme_font_size_override("font_size", 16)
	resources_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.94, 1.0))
	
	traits_label.add_theme_font_size_override("font_size", 16)
	traits_label.add_theme_color_override("font_color", Color(0.88, 0.92, 0.94, 1.0))
	
	_style_menu_button(menu_button)

func _style_menu_button(btn: Button) -> void:
	btn.custom_minimum_size = Vector2(0, 60)
	
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.31, 0.8, 0.77, 0.9)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = Color(0.31, 0.8, 0.77, 0.6)
	normal_style.corner_radius_top_left = 12
	normal_style.corner_radius_top_right = 12
	normal_style.corner_radius_bottom_right = 12
	normal_style.corner_radius_bottom_left = 12
	btn.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style := normal_style.duplicate()
	hover_style.bg_color = Color(0.4, 0.85, 0.82, 0.95)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))

func _on_menu() -> void:
	EventBus.scene_transition.emit("res://scenes/ui/MainMenu.tscn")
