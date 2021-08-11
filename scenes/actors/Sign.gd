extends Sprite

export(NodePath) var canvas_layer
export(PoolStringArray) var text_data

var _player_inside: = false
var _msg_box

func _player_entered(_body):
	_player_inside = true

func _player_exited(_body):
	_player_inside = false

func _unhandled_key_input(event: InputEventKey):
	if _player_inside:
		if event.is_action_pressed("up"):
			_msg_box.start_dialog()
			get_tree().set_input_as_handled()

func _ready():
	var cl = get_node(canvas_layer)
	if not cl:
		push_warning("No canvas layer provided, this node will do nothing")
		set_process_unhandled_key_input(false)
		return
	if not (cl is CanvasLayer):
		push_error(str(canvas_layer, " does not refer to a canvas layer"))
		set_process_unhandled_key_input(false)
		return
	
	_msg_box = load("res://scenes/gui/message_box/MessageBox.tscn")
	_msg_box = _msg_box.instance()
	_msg_box.text_data = text_data
	(cl as Node).add_child(_msg_box)
