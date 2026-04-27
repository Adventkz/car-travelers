# res://scripts/ui/settings_menu.gd
extends Control

@export var music_bus_name: String = "Master"
@export var sfx_bus_name: String = "SFX"

var music_bus_index: int
var sfx_bus_index: int
@onready var music_slider = $WindowPanel/VBoxMain/MusicRow/MusicSlider
@onready var sfx_slider = $WindowPanel/VBoxMain/SfxRow/SfxSlider
@onready var tg_button = $WindowPanel/VBoxMain/SocialRow/TGButton

const TELEGRAM_LINK := "https://t.me/your_bot_link"

func _ready():
	# Получаем индексы шин с проверкой
	music_bus_index = AudioServer.get_bus_index(music_bus_name)
	sfx_bus_index = AudioServer.get_bus_index(sfx_bus_name)
	
	# Если шина SFX не существует, используем Master
	if sfx_bus_index == -1:
		sfx_bus_index = music_bus_index
	
	# Инициализация слайдеров текущими значениями звука
	if music_slider:
		music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_index))
	if sfx_slider:
		sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_index))
	
	# Подключаем сигналы
	if music_slider:
		music_slider.value_changed.connect(_on_music_slider_value_changed)
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	if tg_button:
		tg_button.pressed.connect(_on_tg_button_pressed)
	
	# Закрытие по клику на оверлей
	var overlay = get_node_or_null("SettingsOverlay")
	if overlay:
		overlay.mouse_filter = Control.MOUSE_FILTER_STOP
		overlay.gui_input.connect(_on_overlay_input)

# Изменение громкости Музыки
func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(music_bus_index, value < 0.01)

# Изменение громкости Эффектов
func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(value))
	AudioServer.set_bus_mute(sfx_bus_index, value < 0.01)

# Ссылка на Телеграм
func _on_tg_button_pressed():
	OS.shell_open(TELEGRAM_LINK)

# Закрытие меню по клику на оверлей
func _on_overlay_input(event):
	if event is InputEventMouseButton and event.pressed:
		hide()
