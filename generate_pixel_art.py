#!/usr/bin/env python3
"""
Генератор пиксельных портретов в Minecraft стиле
"""

from PIL import Image, ImageDraw
import os

PORTRAIT_SIZE = 64  # Пиксельный размер (маленький для pixel art)
SCALE = 4  # Масштабирование для финального изображения
FINAL_SIZE = (PORTRAIT_SIZE * SCALE, PORTRAIT_SIZE * SCALE)

# Цвета кожи для разных персонажей
SKIN_COLORS = {
    "saryn": "#E8B89D",
    "asel": "#F5D0C5",
    "daniyar": "#D4A574",
    "zarina": "#F0C8A8",
    "miras": "#E8C4A0",
    "gulnara": "#E5B898",
    "ruslan": "#D9A67C",
    "dina": "#F2C8B0",
    "timur": "#D4A574",
    "ainur": "#F0C8A8",
    "bolat": "#F5D0C5",
    "erlan": "#C9956C",
    "saule": "#E5B898",
    "almaz": "#D4A574",
    "meruert": "#F2C8B0",
    "arman": "#D9A67C",
    "kamila": "#F0C8A8",
    "darkhan": "#F5D0C5",
    "azamat": "#D4A574",
    "assel": "#F2C8B0",
    "maksat": "#D9A67C",
    "aliya": "#F0C8A8",
    "erzhan": "#C9956C",
    "gulzhan": "#E5B898",
    "nurly": "#F5D0C5",
    "sanzhar": "#F0C8A8",
    "dauren": "#D4A574",
    "ainura": "#F2C8B0"
}

# Цвета волос
HAIR_COLORS = {
    "saryn": "#2C1810",
    "asel": "#4A2C2A",
    "daniyar": "#1A0F0A",
    "zarina": "#2C1810",
    "miras": "#4A2C2A",
    "gulnara": "#6B4423",
    "ruslan": "#1A0F0A",
    "dina": "#2C1810",
    "timur": "#1A0F0A",
    "ainur": "#4A2C2A",
    "bolat": "#2C1810",
    "erlan": "#6B4423",
    "saule": "#4A2C2A",
    "almaz": "#1A0F0A",
    "meruert": "#2C1810",
    "arman": "#1A0F0A",
    "kamila": "#4A2C2A",
    "darkhan": "#2C1810",
    "azamat": "#1A0F0A",
    "assel": "#2C1810",
    "maksat": "#1A0F0A",
    "aliya": "#4A2C2A",
    "erzhan": "#6B4423",
    "gulzhan": "#2C1810",
    "nurly": "#4A2C2A",
    "sanzhar": "#2C1810",
    "dauren": "#1A0F0A",
    "ainura": "#2C1810"
}

# Цвета одежды
CLOTHES_COLORS = {
    "saryn": "#3E5F8A",
    "asel": "#C94040",
    "daniyar": "#508A50",
    "zarina": "#E6A23C",
    "miras": "#5B9BD5",
    "gulnara": "#9B59B6",
    "ruslan": "#48B3A8",
    "dina": "#E05C5C",
    "timur": "#7DB34D",
    "ainur": "#4DB8E8",
    "bolat": "#FFD54F",
    "erlan": "#78909C",
    "saule": "#E57373",
    "almaz": "#7E57C2",
    "meruert": "#4DD0E1",
    "arman": "#FF8A65",
    "kamila": "#8D6E63",
    "darkhan": "#FFF176",
    "azamat": "#5C6BC0",
    "assel": "#E0E0E0",
    "maksat": "#A1887F",
    "aliya": "#CE93D8",
    "erzhan": "#80CBC4",
    "gulzhan": "#FFAB91",
    "nurly": "#B39DDB",
    "sanzhar": "#C5E1A5",
    "dauren": "#80DEEA",
    "ainura": "#F48FB1"
}

def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

def draw_pixel_face(img, draw, skin_color, hair_color, clothes_color):
    """Рисует пиксельное лицо в Minecraft стиле"""
    # Фон (прозрачный)
    
    # Лицо (центр)
    face_rect = [16, 16, 48, 48]
    draw.rectangle(face_rect, fill=skin_color)
    
    # Волосы (верх)
    draw.rectangle([12, 8, 52, 20], fill=hair_color)
    draw.rectangle([8, 16, 12, 24], fill=hair_color)
    draw.rectangle([52, 16, 56, 24], fill=hair_color)
    
    # Глаза
    draw.rectangle([20, 28, 28, 36], fill="#1A1A1A")
    draw.rectangle([36, 28, 44, 36], fill="#1A1A1A")
    # Блики в глазах
    draw.rectangle([22, 30, 24, 32], fill="#FFFFFF")
    draw.rectangle([38, 30, 40, 32], fill="#FFFFFF")
    
    # Рот
    draw.rectangle([28, 44, 36, 48], fill="#8B4513")
    
    # Одежда (низ)
    draw.rectangle([12, 48, 52, 60], fill=clothes_color)
    
    return img

def generate_pixel_portrait(char_id):
    dir_path = f"car_travelers/assets/visuals/characters/{char_id}"
    os.makedirs(dir_path, exist_ok=True)
    
    skin_color = hex_to_rgb(SKIN_COLORS.get(char_id, "#E8B89D"))
    hair_color = hex_to_rgb(HAIR_COLORS.get(char_id, "#2C1810"))
    clothes_color = hex_to_rgb(CLOTHES_COLORS.get(char_id, "#3E5F8A"))
    
    # Создаем маленькое пиксельное изображение
    img = Image.new('RGBA', (PORTRAIT_SIZE, PORTRAIT_SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    draw_pixel_face(img, draw, skin_color, hair_color, clothes_color)
    
    # Масштабируем для финального изображения (nearest neighbor для pixel art)
    img_scaled = img.resize(FINAL_SIZE, Image.NEAREST)
    
    path = f"{dir_path}/portrait_neutral.png"
    img_scaled.save(path)
    print(f"Generated pixel portrait: {path}")

def main():
    print("Generating pixel art portraits...")
    
    for char_id in SKIN_COLORS.keys():
        generate_pixel_portrait(char_id)
    
    print("Done! All pixel portraits generated.")

if __name__ == "__main__":
    main()
