tool
extends EditorPlugin

const GradientToImageScene := preload('res://addons/helpers/GradientToImage.tscn')

func _enter_tree() -> void:
	add_tool_menu_item('Convert Gradient To Image', self, '_gradient_dialog')

func _exit_tree() -> void:
	remove_tool_menu_item('Convert Gradient To Image')

func _gradient_dialog(_ud):
	var dlg = GradientToImageScene.instance()
	get_editor_interface().get_file_system_dock().add_child(dlg)
	dlg.show_dialog()
