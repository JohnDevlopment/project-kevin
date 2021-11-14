tool
extends AcceptDialog

export var popup_size := Vector2()

func show_dialog(msg: String) -> void:
	popup_centered(popup_size)
	dialog_text = msg
	set_process(true)
