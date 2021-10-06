extends PanelContainer

func _gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("ui_start"):
			Game.set_paused(false)
			get_tree().set_input_as_handled()
			queue_free()

func _ready() -> void:
	Game.set_paused(true)
	grab_focus()
	var inputs := InputMap.get_action_list("ui_start")
	var input := inputs[0] as InputEvent
	var msg: String = $CenterContainer/PauseLabel.text
	$CenterContainer/PauseLabel.text = msg.replace("[START]", input.as_text())
