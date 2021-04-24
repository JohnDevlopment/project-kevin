extends Node

export(String) var default_state

var physics_function

var _states: = {}

var _state_physics_main: FuncRef
var _state_process_main: FuncRef

func _ready():
	for state in get_children():
		var _name: String = state.name
		if not(state is State): continue
		_states[_name] = state

func change_state(state_name: String, user_data = []):
	var state = _states.get(state_name)
	if not state:
		push_error("no state called '%s' exists" % state_name)
		return
	_state_physics_main = funcref(state, "physics_main")
	_state_process_main = funcref(state, "process_main")
	(state as State).setup(get_parent(), user_data)

func call_physics_main(delta: float):
	if not Engine.is_in_physics_frame():
		push_error("method call_physics_main must be called from within a physics frame")
		return
	_state_physics_main.call_func(delta)

func call_process_main(delta: float = 0.0):
	if not delta:
		delta = get_process_delta_time()
	_state_process_main.call_func(delta)
