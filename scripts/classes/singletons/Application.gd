extends Node

static func is_equal_approx_comp(a, b) -> bool:
	assert(typeof(a) == typeof(b), "parameters are not the same type")
	match typeof(a):
		TYPE_COLOR:
			assert(b is Color, "parameter 'b' not a color")
			return is_equal_approx(a.r, b.r) \
				and is_equal_approx(a.g, b.g) \
				and is_equal_approx(a.b, b.b)
		_:
			push_error("parameter types are not supported here")
	
	return false

func exit(code: int = 0, message: String = "") -> void:
	var error_info = ErrorInfo.new(code, message)
	_exit(error_info)

static func get_cell_size() -> int:
	return ProjectSettings.get_setting("world/2d/cell_size")

static func get_screen_size() -> Vector2:
	return Vector2(
		ProjectSettings.get_setting("display/window/size/width"),
		ProjectSettings.get_setting("display/window/size/height")
	)

static func print_fields(fields: Array) -> void:
	for i in fields:
		print(i.name, " = ", i.value)

func _exit(error_info: ErrorInfo) -> void:
	if error_info.code: error_info.print()
	get_tree().quit(error_info.code)
