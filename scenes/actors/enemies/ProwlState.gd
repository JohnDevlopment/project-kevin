extends State

func _setup():
	(user_data.frames as Sprite).frame = 0
	var root: Enemy = persistant_state
	var anim = root.call("_choose_animation", "Walk")
	(user_data.animation_player as AnimationPlayer).play(anim)
	root.velocity.x = root.direction.x * root.speed_cap.x
	
	var player = (user_data as Dictionary).get("player")
	if not player:
		emit_signal("invalid_state", StateMachine.StateCallMode.PHYSICS)

func physics_main(_delta):
	var root: Enemy = persistant_state
	var diff := root.get_center().distance_to(user_data.player.get_center())
	var speed: float = root.direction.x * root.speed_cap.x
	persistant_state.velocity.x = (speed / 4) if diff < 90 else speed
	

func _kevin_state_changed(_old_state, new_state: int) -> void:
	var A: Actor = persistant_state
	var B: Actor = user_data.player
	var diff := A.get_center().distance_to(B.get_center())
	
	if new_state == 3 and diff < 90.0:
		emit_signal("state_change_request", persistant_state.MyState.KNOCKBACK)
		return
