# res://scripts/autoloads/TraitSystem.gd
extends Node

const TRAITS := [
	"authoritarian", "protector",
	"pragmatic", "idealist",
	"withdrawn", "expressive",
	"reckless", "cautious",
	"playful", "serious",
	"trusting", "guarded",
	"wise", "stubborn",
	"traditional", "adaptive"
]

const MAX_TRAIT_VALUE := 10
const MIN_TRAIT_VALUE := 0

# { char_id: { trait_id: value } }
var _data: Dictionary = {}

func _ready() -> void:
	_init_characters()

func _init_characters() -> void:
	var char_ids := [
		"saryn", "asel", "daniyar", "zarina", "miras",
		"ainur", "bolat", "gulnara", "ruslan"
	]
	for char_id in char_ids:
		_data[char_id] = {}
		for trait_id in TRAITS:
			_data[char_id][trait_id] = 0

func reinforce(char_id: String, trait_id: String, delta: int) -> void:
	if not _data.has(char_id):
		_data[char_id] = {}
	if not _data[char_id].has(trait_id):
		_data[char_id][trait_id] = 0
	_data[char_id][trait_id] = clamp(_data[char_id][trait_id] + delta, MIN_TRAIT_VALUE, MAX_TRAIT_VALUE)
	EventBus.trait_updated.emit(char_id, trait_id, _data[char_id][trait_id])

func get_trait(char_id: String, trait_id: String) -> int:
	if not _data.has(char_id): return 0
	return _data[char_id].get(trait_id, 0)

func check(char_id: String, trait_id: String, min_value: int) -> bool:
	return get_trait(char_id, trait_id) >= min_value

func get_dominant(char_id: String) -> String:
	if not _data.has(char_id): return ""
	var char_traits: Dictionary = _data[char_id]
	var best_trait_id := ""
	var best_val := -1
	for trait_id in TRAITS:
		var val: int = char_traits.get(trait_id, 0)
		if val > best_val:
			best_val = val
			best_trait_id = trait_id
	return best_trait_id

func get_all(char_id: String) -> Dictionary:
	return _data.get(char_id, {}).duplicate()

func serialize() -> Dictionary:
	return _data.duplicate(true)

func deserialize(saved: Dictionary) -> void:
	_data = saved
