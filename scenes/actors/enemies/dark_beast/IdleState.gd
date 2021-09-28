extends State

var triggered := false

func _setup():
	triggered = false
	persistant_state.start_animation_with_blend('Idle', persistant_state.direction)
	if user_data.start_cooldown:
		(user_data.cooldown_timer as Timer).start(1)
		user_data.start_cooldown = false

func physics_main(delta: float):
	var vel: Vector2 = persistant_state.velocity
	if vel.x:
		vel.x = move_toward(vel.x, 0, delta * persistant_state.FRICTION)
		persistant_state.velocity.x = vel.x
	if not (user_data.cooldown_timer as Timer).is_stopped(): return
	if persistant_state.triggered:
		return persistant_state.MyState.PROWL
