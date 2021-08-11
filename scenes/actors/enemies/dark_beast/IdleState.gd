extends State

func _setup():
	var x_dir: float = persistant_state.direction.x
	(user_data[2] as Sprite).frame = 0 if x_dir > 0.0 else 6
	timer1_timeout()

func cleanup():
	(user_data[0] as Timer).stop()
	(user_data[1] as AnimationPlayer).stop()

func physics_main(delta: float):
	var vel: Vector2 = persistant_state.velocity
	if vel.x:
		vel.x = move_toward(vel.x, 0, delta * persistant_state.FRICTION)
		persistant_state.velocity.x = vel.x

func timer1_timeout() -> void:
	var anim = persistant_state._choose_animation("Idle")
	(user_data[1] as AnimationPlayer).play(anim)
