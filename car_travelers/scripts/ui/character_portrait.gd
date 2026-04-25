# res://scripts/ui/character_portrait.gd
extends Control

@onready var portrait_tex: TextureRect = $Portrait
@onready var name_tag: Label = $NameTag
@onready var stress_dot: ColorRect = $StressIndicator

var char_id: String = ""

func setup(cid: String) -> void:
	char_id = cid
	var data: Dictionary = CharacterRegistry.get_data(cid)
	name_tag.text = data.get("display_name", cid)
	set_emotion("neutral")
	EventBus.trait_updated.connect(_on_trait_updated)
	EventBus.resource_changed.connect(_on_resource_changed)

func set_emotion(emotion: String) -> void:
	var path := "res://assets/visuals/characters/%s/portrait_%s.png" % [char_id, emotion]
	if ResourceLoader.exists(path):
		portrait_tex.texture = load(path)
	else:
		portrait_tex.texture = null

func _on_trait_updated(cid: String, _trait_id: String, _val: int) -> void:
	if cid != char_id: return
	_update_stress_dot()

func _on_resource_changed(type: String, value: int) -> void:
	if type == "stress":
		stress_dot.visible = value >= ResourceManager.CRITICAL_STRESS

func _update_stress_dot() -> void:
	stress_dot.visible = ResourceManager.stress >= ResourceManager.CRITICAL_STRESS
