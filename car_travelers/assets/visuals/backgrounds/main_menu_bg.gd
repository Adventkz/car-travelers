# res://assets/visuals/backgrounds/main_menu_bg.gd
extends ColorRect

# --- Анимированный фон с градиентом и частицами ---
var time := 0.0
var particles: Array[Dictionary] = []
var stars: Array[Dictionary] = []

const PARTICLE_COUNT := 25
const STAR_COUNT := 50
const GRADIENT_TOP := Color(0.1, 0.1, 0.18, 1.0)  # #1A1A2E
const GRADIENT_BOTTOM := Color(0.08, 0.13, 0.22, 1.0)  # #16213E
const PARTICLE_COLORS := [Color(0.91, 0.27, 0.38, 0.3), Color(0.31, 0.8, 0.77, 0.25), Color(0.96, 0.65, 0.14, 0.2)]

func _ready() -> void:
	_init_particles()
	_init_stars()

func _process(delta: float) -> void:
	time += delta
	_update_gradient()
	_update_particles(delta)
	_update_stars(delta)
	queue_redraw()

func _init_particles() -> void:
	particles.clear()
	for i in PARTICLE_COUNT:
		particles.append({
			"x": randf() * size.x,
			"y": randf() * size.y,
			"size": randf_range(2.0, 6.0),
			"speed_x": randf_range(-20.0, 20.0),
			"speed_y": randf_range(-10.0, -30.0),
			"color": PARTICLE_COLORS[randi() % PARTICLE_COLORS.size()],
			"alpha": randf_range(0.2, 0.5)
		})

func _init_stars() -> void:
	stars.clear()
	for i in STAR_COUNT:
		stars.append({
			"x": randf() * size.x,
			"y": randf() * size.y,
			"size": randf_range(0.5, 2.0),
			"twinkle_speed": randf_range(1.0, 3.0),
			"twinkle_offset": randf() * PI * 2,
			"alpha": randf_range(0.3, 0.8)
		})

func _update_gradient() -> void:
	# Мягкое пульсирование градиента
	var pulse = (sin(time * 0.5) + 1.0) * 0.5 * 0.05
	var top_color = GRADIENT_TOP.lerp(Color(0.12, 0.12, 0.2, 1.0), pulse)
	var bottom_color = GRADIENT_BOTTOM.lerp(Color(0.1, 0.15, 0.25, 1.0), pulse)
	color = top_color.lerp(bottom_color, 0.5)

func _update_particles(delta: float) -> void:
	for p in particles:
		p.x += p.speed_x * delta
		p.y += p.speed_y * delta
		p.alpha += sin(time * 2.0 + p.x * 0.01) * 0.01 * delta
		
		# Пересоздание частиц при выходе за границы
		if p.y < -10 or p.x < -10 or p.x > size.x + 10:
			p.x = randf() * size.x
			p.y = size.y + 10
			p.alpha = randf_range(0.2, 0.5)

func _update_stars(delta: float) -> void:
	for s in stars:
		# Мерцание звёзд
		s.alpha = 0.3 + 0.5 * (sin(time * s.twinkle_speed + s.twinkle_offset) + 1.0) * 0.5

func _draw() -> void:
	# Отрисовка звёзд
	for s in stars:
		var alpha = clamp(s.alpha, 0.0, 1.0)
		draw_circle(Vector2(s.x, s.y), s.size, Color(1.0, 1.0, 1.0, alpha))
	
	# Отрисовка частиц
	for p in particles:
		var alpha = clamp(p.alpha, 0.0, 0.5)
		draw_circle(Vector2(p.x, p.y), p.size, Color(p.color.r, p.color.g, p.color.b, alpha))
