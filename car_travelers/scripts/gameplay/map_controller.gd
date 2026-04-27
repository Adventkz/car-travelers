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
	var distance_km: float = float(node.get("distance_km", 0))
	var terrain: String = node.get("terrain", "asphalt")
	var fuel_cost: int = ResourceManager.calculate_fuel_cost(distance_km, terrain)
	
	# Если расстояние 0 (стартовый узел), не тратим ресурсы
	if distance_km == 0:
		print("Остаемся на месте: %s" % node.get("display_name", ""))
		return
	
	# Проверяем, есть ли топливо
	if ResourceManager.fuel < fuel_cost:
		# Казуальный режим: всегда находим топливо если не хватает
		var found_fuel := randi_range(10, 25)
		ResourceManager.modify("fuel", found_fuel, "Найдено на заправке")
		ResourceManager.modify("stress", 5, "Задержка в пути")
		print("Найдено топливо: %d (казуальный режим)" % found_fuel)
	
	ResourceManager.modify("fuel", -fuel_cost, "Путешествие")
	ResourceManager.modify("stress", ResourceManager.calculate_stress_delta(), "Путешествие")
	
	# Случайные поломки авто на маршруте (казуальный режим)
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
	
	# Казуальный режим: значительно снижен шанс поломки
	var breakdown_chance := 0.0
	match terrain:
		"asphalt": breakdown_chance = 0.01  # 1% на асфальте
		"dirt": breakdown_chance = 0.03     # 3% на грунте
		"sand": breakdown_chance = 0.05     # 5% на песке
		"mountain": breakdown_chance = 0.08 # 8% в горах
		_: breakdown_chance = 0.02
	
	# Минимальный шанс с расстояния (очень маленький)
	breakdown_chance += distance * 0.001
	
	var roll := randf()
	if roll < breakdown_chance:
		var damage := int(randi_range(5, 15))  # Меньший урон
		ResourceManager.modify("vehicle_hp", -damage)
		print("Авто получило урон: %d HP (местность: %s)" % [damage, terrain])
		
		# Если HP упало до 0, восстанавливаем до минимума вместо Game Over
		if ResourceManager.vehicle_hp <= 0:
			ResourceManager.vehicle_hp = 10
			print("Авто критически повреждено, но можно двигаться (казуальный режим)")
