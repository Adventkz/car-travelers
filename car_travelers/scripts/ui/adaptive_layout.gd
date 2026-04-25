# res://scripts/ui/adaptive_layout.gd
extends Control

signal layout_changed(is_portrait: bool)

var _is_portrait: bool = false

func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_resized)
	_apply_layout()

func _on_viewport_resized() -> void:
	var was_portrait := _is_portrait
	_is_portrait = get_viewport_rect().size.x < get_viewport_rect().size.y
	if was_portrait != _is_portrait:
		_apply_layout()
		layout_changed.emit(_is_portrait)

func _apply_layout() -> void:
	var size := get_viewport_rect().size
	_is_portrait = size.x < size.y
	
	if _is_portrait:
		_apply_portrait_layout()
	else:
		_apply_landscape_layout()

func _apply_portrait_layout() -> void:
	# Переопределить в наследниках
	pass

func _apply_landscape_layout() -> void:
	# Переопределить в наследниках
	pass

func is_portrait() -> bool:
	return _is_portrait

func is_landscape() -> bool:
	return not _is_portrait

func get_safe_area() -> Rect2:
	var viewport_size := get_viewport_rect().size
	var safe_margin_top := 0
	var safe_margin_bottom := 0
	
	if OS.has_feature("android") or OS.has_feature("ios"):
		safe_margin_top = 48
		safe_margin_bottom = 34
	
	return Rect2(
		0,
		safe_margin_top,
		viewport_size.x,
		viewport_size.y - safe_margin_top - safe_margin_bottom
	)
