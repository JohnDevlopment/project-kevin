## A self-contained state, to be used with StateMachine
extends Node
class_name State

## Indicates that the state should be changed
# @arg{int}  new_state  An integer denoting the desired state
signal state_change_request(new_state)

## A custom signal type
# @arg{string}  signal_name  A string with the name of a custom signal
# @arg{array}   args         A list of parameters to pass
signal state_custom_signal(signal_name, args)

## Tells the StateMachine parent to enable part of the active state
# @arg{int} mode  A constant of enum @e StateMachine::StateCallMode
signal state_enable(mode)

## Tells the StateMachine parent to disable part of the active state
# @arg{int} mode  A constant of enum @e StateMachine::StateCallMode
signal state_disable(mode)

## Queue a state for activation
# @arg{int}  state  The next state to add to queue
signal queue_add_state(state)

## The persistant state, from which this state is acted upon
var persistant_state: Object

## User data, passed to each state
var user_data

# warning-ignore-all:shadowed_variable

## Called when exiting a state
# @virtual
# @note     Override this function to implement a custom destructor
func cleanup() -> void: pass

## Returns a metadata value with a default as fallback
# @arg    name     The key for which a metadata is defined
# @arg    default  The default return value if @a name does not exist
# @return          The metadata for @a name (if it exists) or @a default otherwise
func get_meta_or_default(name: String, default = null):
	if has_meta(name):
		return get_meta(name)
	return default

## The main fixed-step physics process for the state
# @virtual
# @arg      delta  The delta step in seconds
func physics_main(_delta: float): pass

## The main idle-frame process for the state
# @virtual
# @arg      delta  The delta step in seconds
func process_main(_delta: float): pass

## Called when entering a state, used for initialization
# @virtual
# @arg     persistant_state  The object modified by the state
# @arg     user_data         User-provided data, if any
func setup(persistant_state, user_data = null) -> void:
	self.persistant_state = persistant_state
	self.user_data = user_data
	if has_method("_setup"): call("_setup")
