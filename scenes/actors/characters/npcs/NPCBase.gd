tool
extends Messenger

export var auto_dialog := false

var _kevin_detected := false

func _ready() -> void:
	if Engine.editor_hint: return
	yield(get_tree(), 'idle_frame')
	if Game.has_player():
		_kevin_detected = $DetectionField.overlaps_body( Game.get_player() )
	
	if auto_dialog:
		$AutoDetectField.connect('body_entered', self, '_on_trigger_auto_detect')
	else:
		$AutoDetectField.queue_free()

func _enter_tree() -> void:
	if Engine.editor_hint:
		set_physics_process(false)

func _unhandled_key_input(event: InputEventKey) -> void:
	if is_active_npc() and not Game.dialog_mode:
		if event.is_action_pressed('up'):
			start_dialog()
			get_tree().set_input_as_handled()

func _physics_process(_delta: float) -> void:
	velocity = move_and_slide(velocity, Vector2.UP, true)

func is_active_npc() -> bool:
	return _kevin_detected
#	Engine.print_error_messages = false
#	var temp_npc = get_meta('active_npc')
#	Engine.print_error_messages = true
#	return is_instance_valid(temp_npc)

func _on_detection_field_state_changed(_body: Node, body_inside: bool) -> void:
	_kevin_detected = body_inside
	if body_inside:
		Game.set_meta('active_npc', self)
		if has_method('_trigger_auto_dialog'):
			call('_trigger_auto_dialog')

func _on_trigger_auto_detect(_body: Node) -> void:
	$AutoDetectField.queue_free()
	start_dialog()
