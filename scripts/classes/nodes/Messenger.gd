tool
extends Actor
class_name Messenger

const MESSAGE_BOX = preload("res://scenes/gui/message_box/MessageBox.tscn")

var canvas_layer: NodePath
var message_data

var _msg_box

func _get(property: String):
	match property:
		"message_data":
			return message_data
		"canvas_layer":
			return canvas_layer

func _get_configuration_warning() -> String:
	if canvas_layer.is_empty():
		return "No path to a canvas layer has been provided. Without that, the message box cannot be displayed."
	
	var cl = get_node_or_null(canvas_layer)
	if not cl:
		return "The node path \"%s\" is invalid." % canvas_layer
	elif not (cl is CanvasLayer):
		return "The node pointed to by \"%s\" is not a CanvasLayer." % canvas_layer
	
	if not message_data:
		return "No MessageData associated with this node. This node will not work without one"
	elif message_data.is_empty():
		return "The MessageData associated with this node has no text defined in it."
	
	return ""

func _get_property_list() -> Array:
	return [
		{
			name = "messenger",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "message_data",
			type = TYPE_OBJECT,
			usage = PROPERTY_USAGE_DEFAULT,
			hint = PROPERTY_HINT_RESOURCE_TYPE
#			hint_string = "Resource"
		},
		{
			name = "canvas_layer",
			type = TYPE_NODE_PATH,
			usage = PROPERTY_USAGE_DEFAULT
		}
	]

func _set(property: String, value) -> bool:
	match property:
		"message_data":
			message_data = value
			update_configuration_warning()
		"canvas_layer":
			canvas_layer = value
			update_configuration_warning()
		_:
			return false
	return true

func render_message_box() -> bool:
	var cl = get_node(canvas_layer)
	if not cl: return false
	
	if not(cl is CanvasLayer):
		push_error("%s is not a CanvasLayer" % canvas_layer)
		return false
	
	_msg_box = MESSAGE_BOX.instance()
	_msg_box.text_data = message_data.get_data()
	cl.add_child(_msg_box)
	
	return true

func show_message_box() -> void:
	if _msg_box:
		_msg_box.start_dialog()
