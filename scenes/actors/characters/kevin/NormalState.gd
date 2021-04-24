extends State

func _setup() -> void:
	print("Initialize 'Normal' state")

func physics_main(delta: float):
	persistant_state.calculate_move_velocity(delta)
	if persistant_state.jump_once:
		persistant_state.velocity.y = -persistant_state.speed_cap.y
