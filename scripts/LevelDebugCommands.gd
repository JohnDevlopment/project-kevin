extends Node

var parent_node: Node
var remote_nodes: = []

const valid_commands: = [
	["kevin_speed", [-1, -1], ["x", "y"]]
]

func kevin_speed(x, y) -> String:
	var result: String
	var kevin: Actor = parent_node.get_node(remote_nodes[0])
	
	match typeof(x):
		TYPE_INT:
			kevin.speed_cap.x = float(x)
			result = str("set X speed cap to ", x)
		TYPE_REAL:
			kevin.speed_cap.x = x
			result = str("set X speed cap to ", x)
		TYPE_STRING:
			if x == "-":
				result = "Set X component to the default, which is %s\n" % Game.globals.default_kevin_speed.x
				kevin.speed_cap.x = Game.globals.default_kevin_speed.x
			else:
				result = "Leave X component to its initial value of %s\n" % kevin.speed_cap.x
		_:
			return "@error:invalid parameter '%s'" % x
	
	match typeof(y):
		TYPE_INT:
			kevin.speed_cap.y = float(y)
			result += str("set Y speed cap to ", y)
		TYPE_REAL:
			kevin.speed_cap.y = y
			result += str("set Y speed cap to ", y)
		TYPE_STRING:
			if y == "-":
				result += "Set Y component to the default, which is %s\n" % Game.globals.default_kevin_speed.y
				kevin.speed_cap.y = Game.globals.default_kevin_speed.y
			else:
				result += "Leave Y component to its initial value of %s\n" % kevin.speed_cap.y
		_:
			return "@error:invalid parameter '%s'" % y
	
	return result
