# res://scripts/gameplay/map_controller.gd
extends Node

var _route_nodes: Array = []
var _current_node: Dictionary = {}

func _ready() -> void:
	_load_route()
	EventBus.scene_transition.connect(func(_t): pass)

func _load_route() -> void:
	var file := FileAccess.open("res://data/routes/chapter_01.json", FileAccess.READ)
	if not file:
		push_error("map_controller: cannot open chapter_01.json")
		return
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("map_controller: JSON parse error")
		return
	_route_nodes = (json.data as Dictionary).get("nodes", [])

func select_node(node_id: String) -> void:
	for node in _route_nodes:
		if node.get("node_id") == node_id:
			_current_node = node
			GameState.current_node_id = node_id
			_travel_to_node(node)
			return
	push_warning("map_controller: node not found: %s" % node_id)

func _travel_to_node(node: Dictionary) -> void:
	var fuel_cost := ResourceManager.calculate_fuel_cost(
		float(node.get("distance_km", 0)),
		node.get("terrain", "asphalt")
	)
	
	# Проверяем, есть ли топливо
	if ResourceManager.fuel < fuel_cost:
		# Шанс найти топливо на маршруте
		var find_fuel_chance := randf()
		if find_fuel_chance < 0.3:  # 30% шанс найти топливо
			var found_fuel := randi_range(5, 15)
			ResourceManager.modify("fuel", found_fuel, "Найдено на маршруте")
			print("Найдено топливо: %d" % found_fuel)
		else:
			_show_game_over("Топливо закончилось! Семья застряла в пустыне.")
			return
	
	ResourceManager.modify("fuel", -fuel_cost, "Путешествие")
	ResourceManager.modify("stress", ResourceManager.calculate_stress_delta(), "Путешествие")
	
	# Случайные поломки авто на маршруте
	_apply_vehicle_damage(node)

	# После каждой поездки обязательно ночёвка в лагере
	GameState.set_phase(GameState.Phase.CAMP)
	EventBus.scene_transition.emit("res://scenes/gameplay/CampScene.tscn")

func _show_game_over(reason: String) -> void:
	GameState.set_game_over(false)
	EventBus.scene_transition.emit("res://scenes/ui/GameOver.tscn")

func _apply_vehicle_damage(node: Dictionary) -> void:
	var terrain: String = node.get("terrain", "asphalt")
	var distance: float = float(node.get("distance_km", 0))
	
	# Шанс поломки зависит от типа местности и расстояния
	var breakdown_chance := 0.0
	match terrain:
		"asphalt": breakdown_chance = 0.05  # 5% на асфальте
		"dirt": breakdown_chance = 0.15     # 15% на грунте
		"sand": breakdown_chance = 0.25     # 25% на песке
		"mountain": breakdown_chance = 0.35 # 35% в горах
		_: breakdown_chance = 0.1
	
	# Увеличиваем шанс с расстоянием
	breakdown_chance += distance * 0.01
	
	var roll := randf()
	if roll < breakdown_chance:
		var damage := int(randi_range(10, 30))
		ResourceManager.modify("vehicle_hp", -damage)
		print("Авто получило урон: %d HP (местность: %s)" % [damage, terrain])
