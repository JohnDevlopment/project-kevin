extends State

func _setup():
	(user_data[2] as Sprite).frame = 0
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
	(user_data[1] as AnimationPlayer).play("IdleLeft")
