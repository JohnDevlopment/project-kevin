extends RichTextLabel

signal message_finished

onready var timer = $MessageTimer

var _speed: = 1.0
var _started := false

func reset():
	bbcode_text = ""
	visible_characters = -1
	visible = false

func start(msg: String, speed: float, delay: float = 1.0):
	if not _started:
		bbcode_text = msg
		visible_characters = 0
		_speed = speed
		if not speed: speed = 1
		timer.wait_time = speed * 0.02
		_started = true
		
		if delay <= 0.0:
			timer.start()
		else:
			yield(get_tree().create_timer(delay), "timeout")
			timer.start()
		
		print("visible_characters = ", visible_characters)

func _on_message_timeout():
	if _speed == 0.0:
		visible_characters = -1
		_handle_finished()
	else:
		visible_characters += 1
		if visible_characters >= text.length():
			_handle_finished()

func _handle_finished():
	_speed = 0
	_started = false
	visible_characters = -1
	timer.stop()
	emit_signal("message_finished")
