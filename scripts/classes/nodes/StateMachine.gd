## Container and controller of states
# @desc  A StateMachine controls the state of an object.
#        Any child that is a State will be added to an internal array of states.
#        An integer index is used to control which state is active through
#        the @c change_state function.
extends Node
class_name StateMachine

signal state_custom_signal(signal_name, signal_args)

## The node being manipulated by the states
export(NodePath) var root_node: NodePath

## State call mode
# @constant  PHYSICS  Physics process
# @constant  PROCESS  Idle process
enum StateCallMode {PHYSICS, PROCESS}

var user_data setget set_user_data
var do_physics: FuncRef
var do_process: FuncRef
var state_queue := []

var _states: = []
var _current_state: int = -1

func _exit_tree() -> void:
	for s in _states:
		(s as Node).queue_free()

func _ready():
	for state in get_children():
		if not (state is State):
			push_warning("node \"%s\" is not a State" % state.name)
			continue
		var s: State = state
		s.connect("state_change_request", self, "_change_state", [], CONNECT_DEFERRED)
		s.connect("queue_add_state", self, "queue_add_state")
		s.connect('state_custom_signal', self, '_process_custom_signal')
		s.connect("state_disable", self, "_state_enable_disable", [false])
		s.connect('state_enable', self, '_state_enable_disable', [true])
		_states.append(s)
		remove_child(s)

## Switch to a different state
# @arg{int}  next_state  The numerical index of the state to switch to
# @note                  For a given state, the parameter will be the child index for the state.
#                        So if the state is the first child of StateMachine, this would be 0.
# @return                A constant of the enumeration @enum Error
func change_state(next_state: int) -> int:
	var old_state = _current_state
	if next_state < 0 or next_state >= _states.size():
		push_error(str("invalid index ", next_state))
		return ERR_PARAMETER_RANGE_ERROR
	
	# Call the cleanup function of the old state
	if old_state >= 0:
		(_states[old_state] as State).cleanup()
	
	# Call the setup function of the new state
	_current_state = next_state
	
	# Reference the physics and idle functions before initializing state
	var temp: State = _states[_current_state]
	do_physics = funcref(temp, "physics_main")
	do_process = funcref(temp, "process_main")
	temp.setup(get_node(root_node), user_data)
	
	return OK

## Get the current (active) state
# @return  The current state as @type int
func current_state() -> int: return _current_state

## Sets the user data that gets passed to each state
func set_user_data(udata) -> void: user_data = udata

## Call a specific method with optional parameters to the active state
# @arg{string}  method  The name of the method to call
# @arg{array}   args    A list of parameters to forward to the method
# @return               The result of @a method
func state_call(method: String, args: Array = []):
	var result
	var state: State = _states[_current_state]
	if state.has_method(method):
		result = state.callv(method, args)
	return result

## Adds the given state to the back of the queue
# @arg{int}  state  Integer index of a state
# @note             If state is out of range, an error is emitted
# @return           A constant of @enum Error
func queue_add_state(state: int) -> int:
	if state < 0 or state >= _states.size():
		push_error(str("Invalid state: ", state))
		return ERR_PARAMETER_RANGE_ERROR
	
	state_queue.push_front(state)
	
	return OK

## Returns true if the queue is empty
# @return  True or false depending on whether the queue is empty
func queue_is_empty() -> bool: return state_queue.empty()

## Switches to the next state in the queue, if any
# @return  The result of @function change_state
func queue_next_state() -> int:
	if queue_is_empty():
		push_error('No states loaded in the queue')
		return FAILED
	
	return change_state(state_queue.pop_back())

# Signal callbacks

func _change_state(new_state: int):
	change_state(new_state)

func _dummy_state(_delta): pass

func _process_custom_signal(signal_name: String, signal_args: Array) -> void:
	emit_signal('state_custom_signal', signal_name, signal_args)

func _state_enable_disable(enable: bool, mode: int) -> void:
	match mode:
		StateCallMode.PHYSICS:
			do_physics = funcref(self, 'physics_main' if enable else '_dummy_state')
		StateCallMode.PROCESS:
			do_process = funcref(self, 'process_main' if enable else '_dummy_state')
		_:
			var fields := []
			fields.append(mode)
			fields.append_array([StateCallMode.PHYSICS, "StateCallMode.PHYSICS"])
			fields.append_array([StateCallMode.PROCESS, "StateCallMode.PROCESS"])
			push_error("invalid mode %d, must be %d (%s) or %d (%s)" % fields)
