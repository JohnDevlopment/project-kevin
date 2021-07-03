extends Node
class_name StateMachine

export(NodePath) var root_node: NodePath

var user_data setget set_user_data
var do_physics: FuncRef
var do_process: FuncRef

var _states: = []
var _current_state: int = -1

func _ready():
	for state in get_children():
		if not (state is State):
			push_error("node \"%s\" is not a valid State instance" % state.name)
			continue
		_states.append(state)

func change_state(next_state: int) -> void:
	var old_state = _current_state
	if next_state < 0 or next_state >= _states.size():
		push_error(str("invalid index ", next_state))
		return
	
	# Call the cleanup function of the old state
	if old_state >= 0:
		(_states[old_state] as State).cleanup()
	
	# Call the setup function of the new state
	_current_state = next_state
	var temp: State = _states[_current_state]
	temp.setup(get_node(root_node), user_data)
	
	do_physics = funcref(temp, "physics_main")
	do_process = funcref(temp, "process_main")

func set_user_data(udata):
	user_data = udata

func state_call(method: String, args: Array = []):
	var result
	var state: State = _states[_current_state]
	if state.has_method(method):
		result = state.callv(method, args)
	return result
