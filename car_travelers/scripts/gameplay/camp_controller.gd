# res://scripts/gameplay/camp_controller.gd
extends Node

func _ready() -> void:
	pass

func start_camp_dialogue(dialogue_id: String) -> void:
	# Для бесконечной игры используем циклические диалоги
	var day_num := GameState.day_count % 10  # Цикл каждые 10 дней
	var cyclic_dialogue_id := "camp_day_%02d" % (day_num + 1)
	
	var file_path := "res://data/dialogues/camp/%s.json" % cyclic_dialogue_id
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("camp_controller: cannot open %s" % file_path)
		return
	
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("camp_controller: JSON parse error in %s" % file_path)
		return
	
	var data: Dictionary = json.data as Dictionary
	var lines: Array = data.get("lines", [])
	
	# Добавляем вариативность - случайный выбор из нескольких линий
	if lines.size() > 1 and randf() < 0.3:
		lines.shuffle()
		lines = lines.slice(0, min(3, lines.size()))
	
	var view := _get_dialogue_view()
	if view:
		view.show_dialogue(cyclic_dialogue_id, lines)
		view.dialogue_finished.connect(_on_dialogue_finished)
	else:
		push_warning("camp_controller: DialogueView autoload not found")

func _on_dialogue_finished(dialogue_id: String) -> void:
	var parent_scene := get_parent()
	if parent_scene and parent_scene.has_method("on_dialogue_finished"):
		parent_scene.on_dialogue_finished()

func end_camp() -> void:
	# Казуальный режим: потребление еды каждую ночь
	var family_size := 6  # 6 человек в семье
	var food_cost := family_size * 2  # 2 еды на человека
	
	# Если еды недостаточно, тратим всё что есть и добавляем штраф стрессу
	if ResourceManager.food < food_cost:
		var actual_cost := ResourceManager.food
		ResourceManager.modify("food", -actual_cost, "Ночёвка (недоедание)")
		ResourceManager.modify("stress", 15, "Голод семьи")
		print("Недостаточно еды! Семья голодает, но продолжает путь (казуальный режим)")
	else:
		ResourceManager.modify("food", -food_cost, "Ночёвка")
	
	# Если еда закончилась, восстанавливаем минимум вместо Game Over
	if ResourceManager.food <= 0:
		ResourceManager.food = 5
		ResourceManager.modify("stress", 10, "Критический голод")
		print("Еда закончилась! Найдено немного припасов (казуальный режим)")
	
	ResourceManager.modify("stress", -5, "Отдых")
	GameState.advance_day()
	GameState.set_phase(GameState.Phase.MAP)
	SaveManager.save_game()
	EventBus.scene_transition.emit("res://scenes/gameplay/MapView.tscn")

func _show_game_over(reason: String) -> void:
	GameState.set_game_over(false)
	EventBus.scene_transition.emit("res://scenes/ui/GameOver.tscn")

func _save_game_result(won: bool, reason: String) -> void:
	var result := {
		"date": Time.get_datetime_string_from_system(false),
		"won": won,
		"day": GameState.day_count,
		"reason": reason,
		"family": GameState.active_family
	}
	
	var history_path := "user://saves/game_history.json"
	var history: Array = []
	
	# Загружаем существующую историю
	var file := FileAccess.open(history_path, FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var data: Dictionary = json.data as Dictionary
			history = data.get("games", [])
		file.close()
	
	# Добавляем новый результат в начало
	history.insert(0, result)
	
	# Ограничиваем до 10 записей
	if history.size() > 10:
		history = history.slice(0, 10)
	
	# Сохраняем
	var save_data := {"games": history}
	var dir := DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")
	
	var save_file := FileAccess.open(history_path, FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_data, "\t"))
		save_file.close()

func _get_dialogue_view() -> Node:
	# DialogueView подключён как autoload или дочерняя сцена
	if Engine.has_singleton("DialogueView"):
		return Engine.get_singleton("DialogueView")
	var root: Node = get_tree().root
	return root.find_child("DialogueView", true, false)
