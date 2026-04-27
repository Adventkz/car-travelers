# res://scripts/ui/main_menu.gd
extends Control

var settings_menu
var start_button
var continue_button
var history_button
var settings_button
var exit_button
var characters_container

func _ready():
	# Получаем узлы
	settings_menu = preload("res://scenes/ui/SettingsMenu.tscn").instantiate()
	characters_container = get_node_or_null("Characters")
	start_button = get_node_or_null("CentralCloud/CloudButtons/StartButton")
	continue_button = get_node_or_null("CentralCloud/CloudButtons/ContinueButton")
	history_button = get_node_or_null("CentralCloud/CloudButtons/HistoryButton")
	settings_button = get_node_or_null("LeftPanel/SettingsButton")
	exit_button = get_node_or_null("ExitButton")
	
	# Скрываем настройки при старте
	add_child(settings_menu)
	settings_menu.hide()
	
	# Подключаем клики персонажей программно
	if characters_container:
		for child in characters_container.get_children():
			if child is TextureButton:
				child.pressed.connect(_on_character_pressed.bind(child))
	
	# Подключаем кнопки
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)
	if continue_button:
		continue_button.pressed.connect(_on_continue_button_pressed)
		continue_button.disabled = not SaveManager.save_exists()
	if history_button:
		history_button.pressed.connect(_on_history_button_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)
	if exit_button:
		exit_button.pressed.connect(_on_exit_button_pressed)

# Логика кнопок
func _on_start_button_pressed():
	GameState.reset_game()
	EventBus.scene_transition.emit("res://scenes/gameplay/MapView.tscn")

func _on_continue_button_pressed():
	SaveManager.load_game()
	EventBus.scene_transition.emit("res://scenes/gameplay/MapView.tscn")

func _on_history_button_pressed():
	EventBus.scene_transition.emit("res://scenes/ui/GameHistory.tscn")

func _on_settings_button_pressed():
	settings_menu.show()

func _on_exit_button_pressed():
	get_tree().quit()

# Анимация персонажа при клике
func _on_character_pressed(character_node):
	var anim_player = character_node.get_node("AnimationPlayer")
	if anim_player:
		# Проигрываем рандомную анимацию или конкретную для этого героя
		if anim_player.has_animation("interact"):
			anim_player.play("interact")
		else:
			# Если нет спец. анимации, делаем простой "прыжок" кодом
			var tween = create_tween()
			tween.tween_property(character_node, "scale", Vector2(1.2, 0.8), 0.1)
			tween.tween_property(character_node, "scale", Vector2(1.0, 1.0), 0.1)
