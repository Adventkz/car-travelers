#!/usr/bin/env python3
"""
Генератор параллакс фонов в пиксельном стиле
"""

from PIL import Image, ImageDraw
import os
import random

BG_SIZE = (1920, 1080)
LAYER_COUNT = 3  # Количество слоёв для параллакса

# Цветовые палитры для разных сцен
PALETTES = {
    "map": {
        "sky": "#87CEEB",
        "ground": "#8B7355",
        "mountains": "#5D4037",
        "trees": "#2E7D32",
        "road": "#4E342E"
    },
    "camp": {
        "sky": "#FF8C00",  # Закат
        "ground": "#3E2723",
        "tent": "#D32F2F",
        "fire": "#FF6F00",
        "stars": "#FFF176"
    },
    "incident": {
        "sky": "#37474F",  # Серое небо
        "ground": "#5D4037",
        "buildings": "#424242",
        "road": "#4E342E"
    },
    "management": {
        "sky": "#4CAF50",
        "ground": "#388E3C",
        "ui_bg": "#1B5E20",
        "highlight": "#81C784"
    }
}

def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def draw_pixel_rect(draw, x, y, w, h, color, pixel_size=4):
    """Рисует прямоугольник в пиксельном стиле"""
    for py in range(y, y + h, pixel_size):
        for px in range(x, x + w, pixel_size):
            draw.rectangle([px, py, px + pixel_size - 1, py + pixel_size - 1], fill=color)

def generate_layer(scene_id, layer_idx, palette):
    """Генерирует один слой параллакса"""
    colors = {k: hex_to_rgb(v) for k, v in palette.items()}
    
    # Чем дальше слой, тем меньше элементов и они медленнее двигаются
    speed_factor = 1.0 - (layer_idx * 0.3)
    scale_factor = 0.5 + (layer_idx * 0.25)
    
    img = Image.new('RGBA', BG_SIZE, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Небо
    draw.rectangle([0, 0, BG_SIZE[0], BG_SIZE[1]], fill=colors["sky"])
    
    if scene_id == "map":
        # Горы (дальний план)
        if layer_idx == 0:
            for i in range(5):
                mx = i * 400 - 100
                my = 400 + random.randint(-50, 50)
                draw_pixel_rect(draw, mx, my, 300, 400, colors["mountains"])
        
        # Холмы (средний план)
        elif layer_idx == 1:
            for i in range(8):
                hx = i * 250 - 50
                hy = 600 + random.randint(-30, 30)
                draw_pixel_rect(draw, hx, hy, 200, 300, colors["ground"])
        
        # Деревья и дорога (ближний план)
        else:
            # Дорога
            draw_pixel_rect(draw, 800, 700, 320, 380, colors["road"])
            # Деревья
            for i in range(15):
                tx = random.randint(0, BG_SIZE[0])
                ty = random.randint(500, 900)
                draw_pixel_rect(draw, tx, ty, 40, 120, colors["trees"])
                draw_pixel_rect(draw, tx - 10, ty - 30, 60, 40, colors["trees"])
    
    elif scene_id == "camp":
        # Звёзды (дальний план)
        if layer_idx == 0:
            for _ in range(100):
                sx = random.randint(0, BG_SIZE[0])
                sy = random.randint(0, 400)
                draw_pixel_rect(draw, sx, sy, 4, 4, colors["stars"])
        
        # Палатка (средний план)
        elif layer_idx == 1:
            draw_pixel_rect(draw, 700, 500, 400, 300, colors["tent"])
            draw_pixel_rect(draw, 850, 400, 100, 100, colors["tent"])
        
        # Костёр и земля (ближний план)
        else:
            draw_pixel_rect(draw, 0, 700, BG_SIZE[0], 380, colors["ground"])
            draw_pixel_rect(draw, 900, 650, 120, 120, colors["fire"])
            # Пламя
            for i in range(5):
                fx = 920 + random.randint(-20, 20)
                fy = 630 + random.randint(-30, 0)
                draw_pixel_rect(draw, fx, fy, 20, 40, "#FF9800")
    
    elif scene_id == "incident":
        # Облака (дальний план)
        if layer_idx == 0:
            for i in range(5):
                cx = i * 400
                cy = 100 + random.randint(-30, 30)
                draw_pixel_rect(draw, cx, cy, 200, 60, "#B0BEC5")
        
        # Здания (средний план)
        elif layer_idx == 1:
            for i in range(6):
                bx = i * 320
                bh = random.randint(200, 400)
                draw_pixel_rect(draw, bx, 600 - bh, 280, bh, colors["buildings"])
        
        # Дорога и детали (ближний план)
        else:
            draw_pixel_rect(draw, 0, 700, BG_SIZE[0], 380, colors["ground"])
            draw_pixel_rect(draw, 800, 700, 320, 380, colors["road"])
    
    elif scene_id == "management":
        # UI элементы (дальний план)
        if layer_idx == 0:
            draw_pixel_rect(draw, 100, 100, 1720, 880, colors["ui_bg"])
        
        # Панели (средний план)
        elif layer_idx == 1:
            draw_pixel_rect(draw, 150, 150, 800, 400, colors["highlight"])
            draw_pixel_rect(draw, 970, 150, 800, 400, colors["highlight"])
        
        # Кнопки и детали (ближний план)
        else:
            for i in range(4):
                bx = 150 + (i % 2) * 820
                by = 600 + (i // 2) * 120
                draw_pixel_rect(draw, bx, by, 380, 100, colors["highlight"])
    
    return img

def generate_parallax_background(scene_id):
    """Генерирует все слои для параллакс фона"""
    dir_path = "car_travelers/assets/visuals/backgrounds"
    os.makedirs(dir_path, exist_ok=True)
    
    palette = PALETTES.get(scene_id, PALETTES["map"])
    
    for layer_idx in range(LAYER_COUNT):
        img = generate_layer(scene_id, layer_idx, palette)
        path = f"{dir_path}/{scene_id}_layer{layer_idx}.png"
        img.save(path)
        print(f"Generated parallax layer: {path}")
    
    # Композитный фон (для использования без параллакса)
    composite = Image.new('RGBA', BG_SIZE, (0, 0, 0, 0))
    for layer_idx in range(LAYER_COUNT):
        layer = generate_layer(scene_id, layer_idx, palette)
        composite = Image.alpha_composite(composite, layer)
    
    path = f"{dir_path}/{scene_id}.png"
    composite.save(path)
    print(f"Generated composite background: {path}")

def main():
    print("Generating parallax backgrounds...")
    
    for scene_id in PALETTES.keys():
        generate_parallax_background(scene_id)
    
    print("Done! All parallax backgrounds generated.")

if __name__ == "__main__":
    main()
