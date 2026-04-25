# res://scripts/autoloads/PlatformManager.gd
extends Node

enum Platform { STEAM, GOOGLE_PLAY, APP_STORE, PC_STANDALONE }

var current: Platform = Platform.PC_STANDALONE

func _ready() -> void:
	if OS.has_feature("steam"):
		current = Platform.STEAM
		# _init_steam()  # раскомментировать при наличии GodotSteam
	elif OS.has_feature("android"):
		current = Platform.GOOGLE_PLAY
	elif OS.has_feature("ios"):
		current = Platform.APP_STORE
	else:
		current = Platform.PC_STANDALONE

func is_steam() -> bool:
	return current == Platform.STEAM

func is_mobile() -> bool:
	return current in [Platform.GOOGLE_PLAY, Platform.APP_STORE]

func is_pc() -> bool:
	return not is_mobile()
