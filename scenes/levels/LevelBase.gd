tool
extends Node2D

export var level_limits := Vector2() setget set_level_limits

var draw_level_limits := false

#func _set(property: String, value) -> bool:
#	pass

func _get_property_list() -> Array:
	return [
		{
			name = 'editor/draw_level_limits',
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		}
	]

func _draw() -> void:
	if Engine.editor_hint:
		if draw_level_limits:
			var drawing_rect := Rect2(Vector2(), level_limits)
			draw_rect(drawing_rect, Color.black)



func set_level_limits(v: Vector2) -> void:
	level_limits = v
	update()
