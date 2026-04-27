# res://scripts/ui/main_menu.gd
extends Control

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var history_button: Button = $VBoxContainer/HistoryButton
@onready var title_label: Label = $VBoxContainer/Title

const HOVER_SCALE := Vector2(1.05, 1.05)
const NORMAL_SCALE := Vector2(1.0, 1.0)
const ANIMATION_DURATION := 0.2

func _ready() -> void:
	start_button.pressed.connect(_on_start)
	continue_button.pressed.connect(_on_continue)
	history_button.pressed.connect(_on_history)
	continue_button.disabled = not SaveManager.save_exists()
	
	# Добавляем hover эффекты для кнопок
	_setup_button_animations(start_button)
	_setup_button_animations(continue_button)
	_setup_button_animations(history_button)
	
	# Анимация заголовка при появлении
	_animate_title_in()

func _setup_button_animations(button: Button) -> void:
	button.mouse_entered.connect(func(): _animate_button_hover(button, true))
	button.mouse_exited.connect(func(): _animate_button_hover(button, false))

func _animate_button_hover(button: Button, is_hovering: bool) -> void:
	var target_scale = HOVER_SCALE if is_hovering else NORMAL_SCALE
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "scale", target_scale, ANIMATION_DURATION)

func _animate_title_in() -> void:
	title_label.modulate.a = 0.0
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(title_label, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(title_label, "position:y", title_label.position.y - 10, 0.5)

func _on_start() -> void:
	GameState.reset_game()
	EventBus.scene_transition.emit("res://scenes/gameplay/MapView.tscn")

func _on_continue() -> void:
	SaveManager.load_game()
	EventBus.scene_transition.emit("res://scenes/gameplay/MapView.tscn")

func _on_history() -> void:
	EventBus.scene_transition.emit("res://scenes/ui/GameHistory.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _animate_button_press(button: Button) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(button, "scale", NORMAL_SCALE, 0.1)
