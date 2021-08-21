tool
extends Messenger

export var enable_physics := false setget set_enable_physics

var _player_inside: = false

func _on_player_entered(_body) -> void:
	_player_inside = true

func _on_player_exited(_body) -> void:
	_player_inside = false

func _physics_process(_delta) -> void:
	if Engine.editor_hint: return
	velocity = move_and_slide(velocity, Vector2.UP)

func _ready() -> void:
	if Engine.editor_hint:
		set_physics_process(false)
		return
	set_physics_process(enable_physics)

func _unhandled_key_input(event: InputEventKey) -> void:
	if _player_inside:
		if event.is_action_pressed("up"):
			get_tree().set_input_as_handled()
			if render_message_box():
				show_message_box()

func set_enable_physics(value: bool):
	enable_physics = value
	set_physics_process(enable_physics)
