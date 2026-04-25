# res://scripts/autoloads/PlatformManager.gd
extends Node

enum Platform { STEAM, GOOGLE_PLAY, APP_STORE, PC_STANDALONE }

var current: Platform = Platform.PC_STANDALONE
var _steam_initialized: bool = false

signal achievement_unlocked(achievement_id: String)
signal cloud_save_completed(success: bool)
signal cloud_save_failed(error: String)

func _ready() -> void:
	if OS.has_feature("steam"):
		current = Platform.STEAM
		_init_steam()
	elif OS.has_feature("android"):
		current = Platform.GOOGLE_PLAY
		_init_mobile()
	elif OS.has_feature("ios"):
		current = Platform.APP_STORE
		_init_mobile()
	else:
		current = Platform.PC_STANDALONE

func _init_steam() -> void:
	# TODO: Интеграция с GodotSteam 4.x
	# Steam.steamInit()
	# _steam_initialized = Steam.isSteamRunning()
	push_warning("PlatformManager: Steam integration not yet implemented")

func _init_mobile() -> void:
	# TODO: Интеграция с мобильными IAP SDK
	push_warning("PlatformManager: Mobile IAP integration not yet implemented")

func is_steam() -> bool:
	return current == Platform.STEAM

func is_mobile() -> bool:
	return current in [Platform.GOOGLE_PLAY, Platform.APP_STORE]

func is_pc() -> bool:
	return not is_mobile()

# --- Достижения (Steam) ---

func unlock_achievement(achievement_id: String) -> void:
	if is_steam() and _steam_initialized:
		# TODO: Steam.setAchievement(achievement_id)
		achievement_unlocked.emit(achievement_id)
	else:
		achievement_unlocked.emit(achievement_id)

# --- Облачные сохранения ---

func save_to_cloud(slot: int = 0) -> void:
	if is_steam() and _steam_initialized:
		# TODO: SteamCloud API
		cloud_save_completed.emit(true)
	elif is_mobile():
		# TODO: Play Games Cloud Save / iCloud
		cloud_save_completed.emit(true)
	else:
		cloud_save_completed.emit(true)

func load_from_cloud(slot: int = 0) -> void:
	if is_steam() and _steam_initialized:
		# TODO: SteamCloud API
		pass
	elif is_mobile():
		# TODO: Play Games Cloud Save / iCloud
		pass

# --- IAP (Mobile) ---

func purchase_iap(product_id: String) -> void:
	if is_mobile():
		# TODO: Mobile IAP purchase
		pass

func restore_purchases() -> void:
	if is_mobile():
		# TODO: Restore purchases
		pass

# --- Статистика (Steam) ---

func set_stat(stat_name: String, value: int) -> void:
	if is_steam() and _steam_initialized:
		# TODO: Steam.setStat(stat_name, value)
		pass

func get_stat(stat_name: String) -> int:
	if is_steam() and _steam_initialized:
		# TODO: Steam.getStat(stat_name)
		return 0
	return 0
