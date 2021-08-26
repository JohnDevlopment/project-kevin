
tool
extends Node2D
class_name DistanceNotifier

signal entered_range(node)
signal exited_range(node)

const X_COMPONENT := 0
const Y_COMPONENT := 1
const BOTH_COMPONENTS := 2
const FLOAT := 3

var other_node: NodePath setget set_other_node
var component: int
var threshold: Vector2 setget set_threshold
var editor_line_color: Color setget set_editor_line_color
var editor_line_range_color := Color.pink setget set_editor_line_range_color
var editor_line_width := 1.0 setget set_editor_line_width

var _other_node: Node2D
var _distance_met := false

func set_editor_line_width(w: float) -> void:
	editor_line_width = w
	update()

#func _draw() -> void:
#	if Engine.editor_hint:
#		if threshold != Vector2.ZERO:
#			var node: Node2D = get_node_or_null(other_node)
#			if not is_instance_valid(node): return
#			var color := editor_line_color
#
#			# Check if within threshold
#			_other_node = node
#			if _check_distance_met():
#				color = color.blend(Color.pink)
#			_other_node = null
#
#			var dest := node.global_position - global_position
#			draw_line(Vector2.ZERO, dest, editor_line_color, 1.0, true)

func _get_configuration_warning() -> String:
	if other_node.is_empty():
		return "You need to specify a node to compare with"
	var temp = get_node_or_null(other_node)
	if not temp:
		return "The node path is invalid."
	if not(temp is Node2D):
		return "The node pointed to by the node path is invalid. It needs to be derived from Node2D."
	if threshold == Vector2.ZERO:
		return "The threshold is zero; the node will not take effect."
	return ""

func _set(property: String, value) -> bool:
	match property:
		"other_node":
			set_other_node(value)
		"component":
			component = value
		"threshold":
			threshold = value
		"editor/line_color":
			set_editor_line_color(value)
		"editor/line_range_color":
			set_editor_line_range_color(value)
		"editor/line_width":
			set_editor_line_width(value)
		_:
			return false
	return true

func _get(property: String):
	match property:
		"other_node":
			return other_node
		"component":
			return component
		"editor/line_color":
			return editor_line_color
		"editor/line_range_color":
			return editor_line_range_color
		"editor/line_width":
			return editor_line_width

func _get_property_list() -> Array:
	return [
		{
			name = "DistanceNotifier",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "other_node",
			type = TYPE_NODE_PATH,
			usage = PROPERTY_USAGE_DEFAULT
		},
		{
			name = "component",
			type = TYPE_INT,
			usage = PROPERTY_USAGE_DEFAULT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = "X,Y,Both,Float"
		},
		{
			name = "threshold",
			type = TYPE_VECTOR2,
			usage = PROPERTY_USAGE_DEFAULT
		},
		{
			name = "editor/line_color",
			type = TYPE_COLOR,
			usage = PROPERTY_USAGE_DEFAULT
		},
		{
			name = "editor/line_range_color",
			type = TYPE_COLOR,
			usage = PROPERTY_USAGE_DEFAULT
		},
		{
			name = "editor/line_width",
			type = TYPE_REAL,
			usage = PROPERTY_USAGE_DEFAULT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "1.0,50.0,0.1"
		}
	]

# Returns true if the other node is within *threshold*
func _check_distance_met() -> bool:
	var met := false
	match component:
		X_COMPONENT:
			var diff := (global_position - _other_node.global_position).abs().x
			met = diff < threshold.x
		Y_COMPONENT:
			var diff := (global_position - _other_node.global_position).abs().y
			met = diff < threshold.y
		BOTH_COMPONENTS:
			var diff := (global_position - _other_node.global_position).abs()
			met = diff < threshold
		FLOAT:
			var diff := global_position.distance_to(_other_node.global_position)
			met = diff < threshold.x
		_:
			# Failsafe
			set_process(false)
	return met

#func _init() -> void:
#	set_notify_transform(true)
#	set_process(false)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			update()
		NOTIFICATION_PROCESS:
			if Engine.editor_hint:
				set_process(false)
				return
			var old_value := _distance_met
			_distance_met = _check_distance_met()
			if old_value != _distance_met:
				if _distance_met:
					emit_signal("entered_range", _other_node)
				else:
					emit_signal("exited_range", _other_node)
		NOTIFICATION_ENTER_TREE:
			print("enter tree")
#			set_process(false)
		NOTIFICATION_READY:
			if Engine.editor_hint:
				print("editor->ready")
				set_process(false)
				return
			var temp = get_node_or_null(other_node)
			var valid := is_instance_valid(temp)
			set_process(valid)
			if valid:
				_other_node = temp as Node2D
		NOTIFICATION_DRAW:
			if Engine.editor_hint:
				if threshold != Vector2.ZERO:
					var node: Node2D = get_node_or_null(other_node)
					if not is_instance_valid(node): return
					
					# Check if within threshold
					var color := editor_line_color
					_other_node = node
					if _check_distance_met():
						color = editor_line_range_color
					_other_node = null
					
					var dest := node.global_position - global_position
					draw_line(Vector2.ZERO, dest, color, editor_line_width, true)

func is_within_range() -> bool: return _distance_met

func set_editor_line_range_color(lbc) -> void:
	editor_line_range_color = lbc
	update()

func set_editor_line_color(lc) -> void:
	editor_line_color = lc
	update()

func set_other_node(v):
	other_node = v
	update_configuration_warning()
	update()

func set_threshold(t) -> void:
	threshold = (t as Vector2).abs()
	update_configuration_warning()
	update()
