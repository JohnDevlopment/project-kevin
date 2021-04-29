extends State

func _setup() -> void:
	print("Initialize 'Normal' state")

func physics_main(delta: float):
	if persistant_state.is_on_floor():
		persistant_state.sprinting = Input.is_action_pressed("dash")
		if persistant_state.jump_once:
			persistant_state.velocity.y = -persistant_state.speed_cap.y
		persistant_state.calculate_move_velocity(delta)
	else:
		persistant_state.sprinting = false
		
	
