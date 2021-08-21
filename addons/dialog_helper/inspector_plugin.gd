extends EditorInspectorPlugin

signal refresh_plugin()

const MessageDataProperty := preload("res://addons/dialog_helper/new_message_data.gd")

var _once := false

func can_handle(object: Object) -> bool:
	return object is Messenger

func parse_category(object: Object, category: String) -> void:
	if category == "messenger":
		add_property_editor("message_data", MessageDataProperty.new())
		_once = true

#func parse_begin(object: Object) -> void:
#	add_property_editor("message_data", MessageDataProperty.new())
