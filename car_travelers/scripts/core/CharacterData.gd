# res://scripts/core/CharacterData.gd
class_name CharacterData
extends Resource

@export var char_id: String = ""
@export var display_name: String = ""
@export var age: int = 0
@export var family_id: String = ""
@export var role: String = ""
@export var portrait_path: String = ""
@export var traits: Dictionary = {}
@export var relationships: Dictionary = {}
@export var biography_key: String = ""
@export var voice_profile: String = ""
