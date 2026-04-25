#!/usr/bin/env python3
"""
Генератор placeholder изображений для портретов и фонов
Запуск: python3 generate_placeholders.py
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Конфигурация
PORTRAIT_SIZE = (256, 256)
BG_SIZE = (1920, 1080)

COLORS = {
    "saryn": "#4A6FA5",
    "asel": "#E57373",
    "daniyar": "#81C784",
    "zarina": "#FFB74D",
    "miras": "#64B5F6",
    "gulnara": "#BA68C8",
    "ruslan": "#4DB6AC",
    "dina": "#F06292",
    "timur": "#AED581",
    "ainur": "#4FC3F7",
    "bolat": "#FFD54F",
    "erlan": "#90A4AE",
    "saule": "#F48FB1",
    "almaz": "#9575CD",
    "meruert": "#4DD0E1",
    "arman": "#FF8A65",
    "kamila": "#A1887F",
    "darkhan": "#FFF176",
    "azamat": "#7986CB",
    "assel": "#E0E0E0",
    "maksat": "#BCAAA4",
    "aliya": "#CE93D8",
    "erzhan": "#80CBC4",
    "gulzhan": "#FFAB91",
    "nurly": "#B39DDB",
    "sanzhar": "#C5E1A5",
    "dauren": "#80DEEA",
    "ainura": "#F48FB1"
}

BG_COLORS = {
    "map": "#2C3E50",
    "camp": "#3E2723",
    "incident": "#4E342E",
    "management": "#1B5E20"
}

def ensure_dir(path):
    os.makedirs(path, exist_ok=True)

def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def generate_portrait(char_id, color_hex):
    dir_path = f"car_travelers/assets/visuals/characters/{char_id}"
    ensure_dir(dir_path)
    
    color = hex_to_rgb(color_hex)
    img = Image.new('RGB', PORTRAIT_SIZE, color)
    draw = ImageDraw.Draw(img)
    
    # Рамка
    draw.rectangle([0, 0, PORTRAIT_SIZE[0]-1, PORTRAIT_SIZE[1]-1], outline='white', width=5)
    
    # Имя персонажа
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 24)
    except:
        font = ImageFont.load_default()
    
    text = char_id.capitalize()
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (PORTRAIT_SIZE[0] - text_width) // 2
    y = (PORTRAIT_SIZE[1] - text_height) // 2
    draw.text((x, y), text, fill='white', font=font)
    
    path = f"{dir_path}/portrait_neutral.png"
    img.save(path)
    print(f"Generated portrait: {path}")

def generate_background(bg_id, color_hex):
    dir_path = "car_travelers/assets/visuals/backgrounds"
    ensure_dir(dir_path)
    
    color = hex_to_rgb(color_hex)
    img = Image.new('RGB', BG_SIZE, color)
    
    # Градиент
    for y in range(BG_SIZE[1]):
        gradient = y / BG_SIZE[1]
        r = int(color[0] * (1 - gradient * 0.3))
        g = int(color[1] * (1 - gradient * 0.3))
        b = int(color[2] * (1 - gradient * 0.3))
        for x in range(BG_SIZE[0]):
            img.putpixel((x, y), (r, g, b))
    
    # Название фона
    draw = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 48)
    except:
        font = ImageFont.load_default()
    
    text = bg_id.upper()
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    x = (BG_SIZE[0] - text_width) // 2
    y = (BG_SIZE[1] - text_height) // 2
    draw.text((x, y), text, fill='white', font=font)
    
    path = f"{dir_path}/{bg_id}.png"
    img.save(path)
    print(f"Generated background: {path}")

def main():
    print("Generating placeholder images...")
    
    # Портреты
    for char_id, color in COLORS.items():
        generate_portrait(char_id, color)
    
    # Фоны
    for bg_id, color in BG_COLORS.items():
        generate_background(bg_id, color)
    
    print("Done! All placeholder images generated.")

if __name__ == "__main__":
    main()
