extends RichTextLabel

signal message_finished

onready var timer = $MessageTimer

var _speed: = 1.0
var _started := false
var _tags := {}

func reset():
	bbcode_text = ""
	visible_characters = -1
	visible = false

func start(msg: String, speed: float, delay: float = 1.0) -> void:
	if _started: return
	
	if speed <= 0.0: speed = 1
	_speed = speed
	timer.wait_time = speed * 0.01
	
	# Set unspecified speed tags to their default values
	if '[speed]' in msg:
		msg = msg.replace('[speed]', "[speed=%f]" % _speed)
	
	# Set unspecified wait tags to their default values
	if '[wait]' in msg:
		msg = msg.replace('[wait]', '[wait=2.0]')
	
	msg = _compile_tag_stack(msg)
	
	bbcode_text = msg
	visible_characters = 0
	_started = true
	
	if delay <= 0.0:
		timer.start()
	else:
		yield(get_tree().create_timer(delay), "timeout")
		timer.start()

func _compile_tag_stack(s: String):
	var regex := RegEx.new()
	regex.compile("\\[[a-z]*=(.+?)\\](.*?)")
	
	var result
	var index: int = s.find('[')
	
	while index >= 0:
		result = regex.search(s)
		if result:
			var setting = result.get_string()
			var values := PoolStringArray(setting.split('='))
			if not (index in _tags):
				_tags[index] = []
			(_tags[index] as Array).append([(values[0] as String).substr(1), float(values[1])])
			s = s.replace(setting, '')
		index = s.find('[')
	return s

func _on_message_timeout() -> void:
	if _speed == 0.0:
		visible_characters = -1
		_handle_finished()
	else:
		timer.start(_speed * 0.01)
		visible_characters += 1
		if visible_characters >= text.length():
			_handle_finished()
			return
		
		var index: int = visible_characters - 1
		if index in _tags:
			for tag in _tags[index]:
				callv("_set_message_parameter", tag)

func _set_message_parameter(param: String, value: float):
	match param:
		"speed":
			_speed = value
		"wait":
			timer.stop()
			visible_characters -= 1
			_tags.erase(visible_characters)
			$WaitTimer.start(value)
			yield($WaitTimer, "timeout")
			timer.start()

func _handle_finished() -> void:
	_speed = 0
	_started = false
	visible_characters = -1
	timer.stop()
	$WaitTimer.stop()
	_tags.clear()
	emit_signal("message_finished")
