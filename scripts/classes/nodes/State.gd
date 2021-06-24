extends Node
class_name State

var change_state: FuncRef
var persistant_state: Object
var user_data

# warning-ignore-all:shadowed_variable

# Called when exiting a state; used for cleanup, as the name suggests.
# Override _cleanup for custom code:
#   void _cleanup()
func cleanup() -> void:
	if has_method("_cleanup"): call("_cleanup")

# The main physics process for the state. Override this function
# to implement it.
func physics_main(_delta: float): pass

# The main idle process for the state. Override this function
# to implement it.
func process_main(_delta: float): pass

# Do not override this function. Override _setup instead to add custom setup
# code for a state.
#   void _setup()
func setup(persistant_state, user_data = null) -> void:
	self.persistant_state = persistant_state
	self.user_data = user_data
	if has_method("_setup"): call("_setup")