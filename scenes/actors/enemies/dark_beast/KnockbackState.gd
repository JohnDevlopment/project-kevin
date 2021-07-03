extends State

var delay: int = 1

func _setup():
	var root: Enemy = persistant_state as Enemy
	root.position.y -= 2
	
	var dir: Vector2
	if root.has_meta("knockback_direction"):
		var temp = root.get_meta("knockback_direction")
		dir = temp
	else:
		var temp = root.direction
		dir = temp
	dir.x = round(dir.x)
	
	root.velocity = Vector2(-dir.x * root.speed_cap.x, -root.speed_cap.y)

#func cleanup():
#	persistant_state.velocity.x = 0

func process_main(_delta):
	(user_data[2] as Sprite).frame = 5

func physics_main(_delta):
	if not delay:
		if (persistant_state as Actor).is_on_floor():
			return {state = persistant_state.MyState.IDLE}
	else:
		delay -= 1
