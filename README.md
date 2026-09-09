# Car Travelers

Нарративная игра об автопутешествии двух семей, сделанная на Godot.

## Движок

- Godot 4.6 (GL Compatibility)
- Язык: GDScript

## Как запустить

1. Установите [Godot 4.6](https://godotengine.org/download).
2. Откройте `car_travelers/project.godot` в редакторе Godot.
3. Запустите проект (F5), стартовая сцена — `scenes/ui/MainMenu.tscn`.

## Структура проекта

```
car_travelers/
├── addons/            # сторонние аддоны (Dialogue Manager)
├── assets/            # спрайты, аудио, шрифты, визуальные ассеты
├── data/              # данные: персонажи, диалоги, инциденты, маршруты
├── export/            # пресеты экспорта Godot
├── localization/       # локализация
├── scenes/             # сцены (core, gameplay, ui, dialogue, characters)
└── scripts/            # GDScript-код (autoloads, core, gameplay, ui, ...)
```

Ассеты (спрайты, иконки, звуки) сгенерированы локальными Python-скриптами в корне репозитория (`generate_*.py`).

## Сторонние компоненты

Проект использует [Dialogue Manager](https://github.com/nathanhoad/godot_dialogue_manager) (`car_travelers/addons/dialogue_manager`) — аддон для Godot от Nathan Hoad, распространяется по лицензии MIT (см. `LICENSE` внутри папки аддона).

## Лицензия

См. [LICENSE](LICENSE). Лицензия распространяется на код и ассеты игры за пределами `addons/dialogue_manager`, который лицензирован отдельно.
