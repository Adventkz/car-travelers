#!/usr/bin/env python3
"""Конвертация SVG иконок в PNG для Godot"""
import os
import subprocess
from pathlib import Path

# Путь к директории с иконками
icons_dir = Path("/Users/yestayseitembetov/Documents/car travelers/car_travelers/assets/ui/icons")
output_dir = icons_dir / "png"

# Создаем директорию для PNG
output_dir.mkdir(exist_ok=True)

# Список SVG файлов для конвертации
svg_files = [
    "icon_start.svg",
    "icon_continue.svg",
    "icon_settings.svg",
    "icon_headphones.svg",
    "icon_flower.svg",
    "icon_book.svg"
]

# Размер иконок
size = 64

for svg_file in svg_files:
    svg_path = icons_dir / svg_file
    png_path = output_dir / svg_file.replace(".svg", ".png")
    
    if svg_path.exists():
        # Используем rsvg-convert или inkscape для конвертации
        try:
            # Попробуем rsvg-convert (быстрее)
            subprocess.run([
                "rsvg-convert",
                "-w", str(size),
                "-h", str(size),
                "-o", str(png_path),
                str(svg_path)
            ], check=True)
            print(f"✓ Конвертировано: {svg_file}")
        except (subprocess.CalledProcessError, FileNotFoundError):
            try:
                # Попробуем inkscape
                subprocess.run([
                    "inkscape",
                    "--export-type=png",
                    f"--export-filename={png_path}",
                    f"--export-width={size}",
                    f"--export-height={size}",
                    str(svg_path)
                ], check=True)
                print(f"✓ Конвертировано (inkscape): {svg_file}")
            except (subprocess.CalledProcessError, FileNotFoundError):
                print(f"✗ Не удалось конвертировать: {svg_file}")
                print("  Установите librsvg или inkscape для конвертации SVG")
    else:
        print(f"✗ Файл не найден: {svg_file}")

print("\nКонвертация завершена!")
