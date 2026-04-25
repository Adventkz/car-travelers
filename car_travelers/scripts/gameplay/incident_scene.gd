# res://scripts/gameplay/incident_scene.gd
extends Control

@onready var title_label: Label = $CenterContainer/TitleLabel
@onready var desc_label: Label = $CenterContainer/DescriptionLabel
@onready var choices_container: VBoxContainer = $CenterContainer/ChoicesContainer

var _controller: Node

func _ready() -> void:
	_controller = Node.new()
	_controller.set_script(load("res://scripts/gameplay/incident_controller.gd"))
	add_child(_controller)
	_controller.incident_choices_ready.connect(_populate_ui)
	_controller.start_random()

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
		choices_container.add_child(btn)
