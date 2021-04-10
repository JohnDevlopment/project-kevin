extends Node
class_name State

var change_state: FuncRef
var persistant_state: Object
var user_data: Array setget set_user_data

# Override this function to institute a destructor for the state.
func cleanup() -> void:
	pass

# Override this function to return a string name for the state.
func get_name() -> String:
	return "unknown"

# The main physics process for the state. Override this function
# to implement it.
func physics_main(_delta: float) -> void: pass

# The main idle process for the state. Override this function
# to implement it.
func process_main(_delta: float) -> void: pass

# Do not override this function. Override _setup instead to add custom setup
# code for a state.
#   void _setup()
func setup(pers_state, chg_state: FuncRef, udata = []) -> void:
	persistant_state = pers_state
	change_state = chg_state
	set_user_data(udata)
	if has_method("_setup"): call("_setup")

func set_user_data(udata: Array) -> void:
	user_data = udata
