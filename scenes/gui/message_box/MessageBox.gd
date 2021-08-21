extends AspectRatioContainer

export(float, 0.5, 100.0, 0.1) var message_speed = 0.5
export(float, 0.0, 50.0, 0.1) var delay = 0.0

var text_data: PoolStringArray

var _can_advance: = false
var _index: = 0

func reset():
	visible = false
	_index = 0

func start_dialog():
	assert(not text_data.empty())
	$DlgBox/DlgText.start(text_data[_index], message_speed, delay)
	Game.dialog_mode = true
	_can_advance = false
	visible = true

# Called when a message is finished rendering.
func _handle_message_finished():
	_can_advance = true

# Called when the dialog box is no longer needed.
func _handle_all_messages_finished():
	_can_advance = false
	Game.dialog_mode = false
	reset()

func _unhandled_key_input(event: InputEventKey):
	if event.is_action_pressed("ui_accept"):
		if not _can_advance:
			$DlgBox/DlgText._handle_finished()
#			_handle_message_finished()
			_can_advance = true
			return
		
		_index += 1
		if _index >= text_data.size():
			_handle_all_messages_finished()
			return
		
		$DlgBox/DlgText.start(text_data[_index], message_speed, delay)
		_can_advance = false

func _enter_tree():
	visible = false
