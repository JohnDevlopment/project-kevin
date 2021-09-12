extends State

var triggered := false

func _setup():
	triggered = false
	persistant_state.start_animation_with_blend('Idle', persistant_state.direction)

func physics_main(delta: float):
	var vel: Vector2 = persistant_state.velocity
	if vel.x:
		vel.x = move_toward(vel.x, 0, delta * persistant_state.FRICTION)
		persistant_state.velocity.x = vel.x
	if persistant_state.triggered:
		return persistant_state.MyState.PROWL
