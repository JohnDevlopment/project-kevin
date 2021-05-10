extends Node

var parent_node: Node
var remote_nodes: = []
var initial_position: = Vector2()

const valid_commands: = [
	["kevin_speed", [-1, -1], ["x", "y"]],
	["kevin_velocity", [TYPE_VECTOR2], ["velocity"]],
	["kevin_animation", [TYPE_STRING, TYPE_REAL], ["animation", "speed"]],
	["reset_position", [], []]
]

func kevin_speed(x, y) -> String:
	var result: String
	var kevin: Actor = parent_node.get_node(remote_nodes[0])
	
	match typeof(x):
		TYPE_INT:
			kevin.speed_cap.x = float(x)
			result = str("set X speed cap to ", x, "\n")
		TYPE_REAL:
			kevin.speed_cap.x = x
			result = str("set X speed cap to ", x, "\n")
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
				result += "Set Y component to the default, which is %s" % Game.globals.default_kevin_speed.y
				kevin.speed_cap.y = Game.globals.default_kevin_speed.y
			else:
				result += "Leave Y component to its initial value of %s" % kevin.speed_cap.y
		_:
			return "@error:invalid parameter '%s'" % y
	
	return result

func kevin_velocity(velocity: Vector2) -> String:
	var kevin: Actor = parent_node.get_node(remote_nodes[0])
	if kevin.is_on_floor():
		return "@error:Kevin must be in the air for this to work."
	kevin.velocity = velocity
	return str("Set Kevin's velocity to ", velocity)

func kevin_animation(animation: String, speed: float) -> String:
	var kevin: Actor = parent_node.get_node(remote_nodes[0])
	var animation_player: AnimationPlayer = kevin.get_node("AnimationPlayer")
	
	if not animation_player.has_animation(animation):
		return "@error:no animation called \"%s\"" % animation
	
	animation_player.play(animation, -1, speed)
	
	return "playing animation '%s' at %f speed" % [animation, speed]

func kevin_gravity_vector(vec: Vector2):
	var kevin: Actor = parent_node.get_node(remote_nodes[0])
	kevin.gravity_vector = vec
	return str("set player gravity vector to ", vec)

func math_map_range(value: float, imin: float, imax: float, omin: float, omax: float):
	var mapped_value = range_lerp(value, imin, imax, omin, omax)
	var result = "map %f to [%f,%f]" % [value, omin, omax]
	return str(result, ": ", mapped_value)

func reset_position() -> String:
	var kevin: Actor = parent_node.get_node(remote_nodes[0])
	kevin.global_position = initial_position
	return str("reset Kevin's position to ", initial_position)
