# res://scripts/gameplay/camp_scene.gd
extends Control

@onready var day_label: Label = $VBox/DayLabel
@onready var dialogue_btn: Button = $VBox/DialogueButton
@onready var sleep_btn: Button = $VBox/SleepButton

var _controller: Node

func _ready() -> void:
	_controller = Node.new()
	_controller.set_script(load("res://scripts/gameplay/camp_controller.gd"))
	add_child(_controller)

	day_label.text = "День %d" % GameState.day_count
	dialogue_btn.pressed.connect(_on_dialogue)
	sleep_btn.pressed.connect(_controller.end_camp)

func _on_dialogue() -> void:
	_controller.start_camp_dialogue("camp_day_%02d" % GameState.day_count)
