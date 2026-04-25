# res://scripts/utils/placeholder_generator.gd
extends Node

# Генерирует placeholder изображения для портретов и фонов
# Запускается один раз при первом запуске игры

const PORTRAIT_SIZE := Vector2i(256, 256)
const BG_SIZE := Vector2i(1920, 1080)

var _colors := {
	"saryn": Color("#4A6FA5"),
	"asel": Color("#E57373"),
	"daniyar": Color("#81C784"),
	"zarina": Color("#FFB74D"),
	"miras": Color("#64B5F6"),
	"gulnara": Color("#BA68C8"),
	"ruslan": Color("#4DB6AC"),
	"dina": Color("#F06292"),
	"timur": Color("#AED581"),
	"ainur": Color("#4FC3F7"),
	"bolat": Color("#FFD54F"),
	"erlan": Color("#90A4AE"),
	"saule": Color("#F48FB1"),
	"almaz": Color("#9575CD"),
	"meruert": Color("#4DD0E1"),
	"arman": Color("#FF8A65"),
	"kamila": Color("#A1887F"),
	"darkhan": Color("#FFF176"),
	"azamat": Color("#7986CB"),
	"assel": Color("#E0E0E0"),
	"maksat": Color("#BCAAA4"),
	"aliya": Color("#CE93D8"),
	"erzhan": Color("#80CBC4"),
	"gulzhan": Color("#FFAB91"),
	"nurly": Color("#B39DDB"),
	"sanzhar": Color("#C5E1A5"),
	"dauren": Color("#80DEEA"),
	"ainura": Color("#F48FB1")
}

var _bg_colors := {
	"map": Color("#2C3E50"),
	"camp": Color("#3E2723"),
	"incident": Color("#4E342E"),
	"management": Color("#1B5E20")
}

func _ready() -> void:
	_generate_all_placeholders()
	queue_free()

func _generate_all_placeholders() -> void:
	_ensure_directory_exists("res://assets/visuals/characters/")
	_ensure_directory_exists("res://assets/visuals/backgrounds/")
	
	# Генерируем портреты
	for char_id in _colors:
		_generate_portrait(char_id, _colors[char_id])
	
	# Генерируем фоны
	for bg_id in _bg_colors:
		_generate_background(bg_id, _bg_colors[bg_id])
	
	print("PlaceholderGenerator: Generated all placeholder images")

func _ensure_directory_exists(path: String) -> void:
	DirAccess.make_dir_absolute(path)

func _generate_portrait(char_id: String, color: Color) -> void:
	var dir_path := "res://assets/visuals/characters/" + char_id
	_ensure_directory_exists(dir_path)
	
	var image := Image.create(PORTRAIT_SIZE.x, PORTRAIT_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(color)
	
	# Добавляем простую рамку
	for x in range(PORTRAIT_SIZE.x):
		for y in range(PORTRAIT_SIZE.y):
			if x < 5 or x > PORTRAIT_SIZE.x - 5 or y < 5 or y > PORTRAIT_SIZE.y - 5:
				image.set_pixel(x, y, Color.WHITE)
	
	var path := dir_path + "/portrait_neutral.png"
	image.save_png(path)
	print("Generated portrait: ", path)

func _generate_background(bg_id: String, color: Color) -> void:
	var image := Image.create(BG_SIZE.x, BG_SIZE.y, false, Image.FORMAT_RGBA8)
	image.fill(color)
	
	# Добавляем градиент
	for y in range(BG_SIZE.y):
		var gradient := float(y) / BG_SIZE.y
		var pixel_color := color.lerp(color.darkened(0.3), gradient)
		for x in range(BG_SIZE.x):
			image.set_pixel(x, y, pixel_color)
	
	var path := "res://assets/visuals/backgrounds/" + bg_id + ".png"
	image.save_png(path)
	print("Generated background: ", path)
