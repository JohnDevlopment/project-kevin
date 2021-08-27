extends State

var triggered := false

func _setup():
	(user_data.frames as Sprite).frame = 0
	triggered = false
	timer1_timeout()

func cleanup():
	(user_data.timer as Timer).stop()
	(user_data.animation_player as AnimationPlayer).stop()

func physics_main(delta: float):
	var vel: Vector2 = persistant_state.velocity
	if vel.x:
		vel.x = move_toward(vel.x, 0, delta * persistant_state.FRICTION)
		persistant_state.velocity.x = vel.x
	if persistant_state.triggered:
		return persistant_state.MyState.PROWL

func timer1_timeout() -> void:
	if triggered:
		(persistant_state.state_machine as StateMachine).call_deferred("change_state", persistant_state.MyState.PROWL)
		return
	var anim = persistant_state._choose_animation("Idle")
	(user_data.animation_player as AnimationPlayer).play(anim)
