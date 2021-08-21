extends EditorProperty

signal refresh_plugin()

var _new_button := Button.new()
var _current_value

func _init() -> void:
	add_child(_new_button)
	_new_button.text = "New MessageData"
	_new_button.connect("pressed", self, "_on_button_pressed")

func _on_button_pressed():
	if _current_value:
		_current_value = null
		_new_button.text = "New MessageData"
	else:
		_current_value = MessageData.new()
		_current_value.set_meta("owner", get_edited_object())
		_new_button.text = "Clear MessageData"
	emit_changed(get_edited_property(), _current_value)

func update_property() -> void:
	if not _current_value:
		_new_button.text = "New MessageData"
	
	var new_value = get_edited_object()[get_edited_property()]
	if new_value == _current_value:
		return
	
	_current_value = new_value
	if not _current_value:
		_new_button.text = "New MessageData"
	else:
		_new_button.text = "Clear MessageData"
