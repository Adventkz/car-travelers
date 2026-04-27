# res://scripts/autoloads/EventBus.gd
extends Node

# --- Ресурсы ---
signal resource_changed(type: String, value: int)
signal resource_critical(type: String)

# --- Трейты ---
signal trait_updated(char_id: String, trait_id: String, value: int)

# --- Инциденты ---
signal incident_started(id: String)
signal incident_resolved(id: String, choice: int)

# --- Диалоги ---
signal dialogue_ended(id: String)
signal start_direction_selected(direction: String)

# --- Сцены ---
signal scene_transition(target: String)

# --- Игровой цикл ---
signal day_ended(day_number: int)
signal phase_changed(phase: int)
