# res://scripts/ui/dialogue_ui.gd
extends Control

func _on_dialogue_mutation(mutation_name: String, extra: Dictionary) -> void:
	match mutation_name:
		"TraitSystem.reinforce":
			TraitSystem.reinforce(
				extra.get("char_id", ""),
				extra.get("trait", ""),
				int(extra.get("delta", 0))
			)
		"ResourceManager.modify":
			ResourceManager.modify(
				extra.get("type", ""),
				int(extra.get("delta", 0))
			)

func _on_dialogue_ended(dialogue_id: String) -> void:
	EventBus.dialogue_ended.emit(dialogue_id)
