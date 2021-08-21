tool
extends EditorPlugin

var DockScene := preload("res://addons/dialog_helper/sign_helper.tscn")

var _dock: Control
var _show_button: ToolButton

func _enter_tree() -> void:
	_dock = DockScene.instance() as Control
	_show_button = add_control_to_bottom_panel(_dock, "MessageData")
	_show_button.hide()
	print("is in tree: ", is_inside_tree())

func _exit_tree() -> void:
	if _dock:
		remove_control_from_bottom_panel(_dock)
		_dock.queue_free()
		_dock = null
	else:
		printerr("_dock is Null prior to its removal from the bottom panel")

func apply_changes() -> void:
	_dock.call("apply_changes")

func edit(object: Object) -> void:
	_dock.call("edit", object as MessageData)

#func enable_plugin() -> void:
#	print("enabled dialog_helper plugin")

func handles(object: Object) -> bool:
	return object is MessageData

func make_visible(visible: bool) -> void:
	if not _dock:
		printerr("make_visible(): _dock is Null")
		return
	
	if visible:
		_show_button.show()
		make_bottom_panel_item_visible(_dock)
	else:
		_show_button.hide()
		if _dock.is_visible_in_tree():
			hide_bottom_panel()
