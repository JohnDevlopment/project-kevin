tool
extends Node
class_name ActionQueue

func _get_property_list() -> Array:
	return [
		{
			name = "ActionQueue",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		}
	]
