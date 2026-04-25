# res://scripts/ui/character_select_controller.gd
extends Control

signal family_selected(family_id: String)

@onready var family_a_button := $VBoxContainer/FamilyAButton
@onready var family_b_button := $VBoxContainer/FamilyBButton
@onready var family_a_preview := $VBoxContainer/FamilyAPreview
@onready var family_b_preview := $VBoxContainer/FamilyBPreview
@onready var start_button := $VBoxContainer/StartButton
@onready var back_button := $VBoxContainer/BackButton

var _selected_family: String = ""

func _ready() -> void:
	family_a_button.pressed.connect(_on_family_a_selected)
	family_b_button.pressed.connect(_on_family_b_selected)
	start_button.pressed.connect(_on_start_game)
	back_button.pressed.connect(_on_back_to_menu)
	
	start_button.disabled = true
	_update_previews()

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
	family_a_button.modulate = Color.WHITE if _selected_family == "family_a" else Color(0.7, 0.7, 0.7)
	family_b_button.modulate = Color.WHITE if _selected_family == "family_b" else Color(0.7, 0.7, 0.7)

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
