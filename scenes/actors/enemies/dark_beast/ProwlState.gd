extends State

func _setup():
	if user_data.start_cooldown:
		user_data.start_cooldown = false
		(user_data.cooldown_timer as Timer).start()
		emit_signal('state_disable', StateMachine.StateCallMode.PHYSICS)
	else:
		var root: Enemy = persistant_state
		root.velocity.x = root.direction.x * root.speed_cap.x
		root.start_animation_with_blend('Walk', root.direction)

func physics_main(_delta):
	if not (user_data.cooldown_timer as Timer).is_stopped():
		return
	
	var root: Enemy = persistant_state
	var diff := root.get_center().distance_to(user_data.player.get_center())
	
	var speed: float = root.direction.x * root.speed_cap.x
	root.velocity.x = (speed / 3.0) if diff < 80.0 else speed
	
	if diff < persistant_state.ATTACK_RANGE:
		return root.MyState.ATTACK

func _kevin_attacking() -> void:
	if (user_data.cooldown_timer as Timer).is_stopped():
		var A: Actor = persistant_state
		var B: Actor = user_data.player
		
		var diff := A.get_center().distance_to(B.get_center())
		if diff < (persistant_state.ATTACK_RANGE + 10.0):
			emit_signal("state_change_request", persistant_state.MyState.EVADE)
			return

func _cooldown_timer_timeout() -> void:
	emit_signal('state_change_request', persistant_state.MyState.PROWL)
