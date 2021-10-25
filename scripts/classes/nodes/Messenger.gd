## An actor that displays a message.
tool
extends Actor
class_name Messenger

## Dialogic timeline
# @type String
var timeline := ""

## Root node to which the dialog is added
# @type NodePath
var root_node: NodePath

var _root: Node2D

func _enter_tree() -> void:
	update_configuration_warning()

func _ready() -> void:
	if Engine.editor_hint: return
	var temp = get_node(root_node)
	if temp and (temp is Node2D):
		_root = temp
	print("gravity_value = ", gravity_value)

func _get(property: String):
	match property:
		"timeline":
			return timeline
		"root_node":
			return root_node

func _set(property: String, value) -> bool:
	match property:
		"timeline":
			timeline = value
			update_configuration_warning()
		"root_node":
			root_node = value
			update_configuration_warning()
		_:
			return false
	return true

func _get_property_list() -> Array:
	return [
		{
			name = "Messenger",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "timeline",
			type = TYPE_STRING,
			usage = PROPERTY_USAGE_DEFAULT
		},
		{
			name = "root_node",
			type = TYPE_NODE_PATH,
			usage = PROPERTY_USAGE_DEFAULT
		}
	]

func _get_configuration_warning() -> String:
	var warnings := PoolStringArray([])
	
	if root_node.is_empty():
		warnings.push_back("No root node has been specified. You need a root node in order for the dialog box to be displayed.")
	if timeline.empty():
		warnings.push_back("No timeline has been specified. In order for Dialogic to work, you need to specify which timeline you want it to show.")
	return warnings.join("\n\n")

func _physics_process(_delta: float) -> void:
	velocity = move_and_slide(velocity, Vector2.UP, true)

func start_dialog(tm: String = ""):
	if tm.empty(): tm = timeline
	var dlg = Dialogic.start(tm)
	if is_instance_valid(_root) and _root.is_inside_tree():
		_root.add_child(dlg)
		dlg.connect("timeline_end", self, "_timeline_complete")
		Game.set_dialog_mode(true)

# Signal callbacks

func _timeline_complete(_tm):
	print('turning off dialog mode')
	Game.set_dialog_mode(false)
