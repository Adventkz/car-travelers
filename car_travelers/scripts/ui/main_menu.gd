# res://scripts/ui/main_menu.gd
extends Control

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton

func _ready() -> void:
	start_button.pressed.connect(_on_start)
	continue_button.pressed.connect(_on_continue)
	continue_button.disabled = not SaveManager.save_exists()

func _on_start() -> void:
	SaveManager.reset()
	EventBus.scene_transition.emit("res://scenes/gameplay/MapView.tscn")

func _on_continue() -> void:
	SaveManager.load_game()
	EventBus.scene_transition.emit("res://scenes/gameplay/MapView.tscn")
