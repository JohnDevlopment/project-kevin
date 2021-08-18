extends VBoxContainer

export var temp := Vector2.ZERO
export var read_only := false

var _current_value: Vector2

func get_value() -> Vector2:
	return _current_value

func _update_value(new_text: String, sub_path: String, comp: String) -> void:
	var old_value = get_indexed("_current_value:" + comp)
	if not new_text.is_valid_float():
		var edit = get_node(sub_path + "/LineEdit")
		edit.text = str(old_value)
		return
	set_indexed("_current_value:" + comp, new_text.to_float())

func _on_LineEdit_need_current_value(path: NodePath, component: String):
	var input: LineEdit = get_node(path)
	input.text = str( get_indexed("_current_value:" + component) )
