extends State

var on_floor: = false

func _setup():
	var root: Enemy = persistant_state
	
	# Updates the on_* flags
	root.move_and_slide(Vector2(0, -1), Vector2.UP)
	
	var dir: Vector2 = root.get_meta_or_default("knockback_direction", root.direction)
	dir.x = round(dir.x)
	root.velocity = Vector2(-dir.x * 100, -root.speed_cap.y)
	on_floor = false

#func cleanup():
#	persistant_state.velocity.x = 0

func process_main(_delta):
	if on_floor:
		(user_data[2] as Sprite).frame = 6
	else:
		(user_data[2] as Sprite).frame = 5

func physics_main(delta):
	var root: Enemy = persistant_state
	if on_floor:
		root.velocity.x = move_toward(root.velocity.x, 0, delta * root.FRICTION)
		if root.velocity.x == 0.0:
			return {state = persistant_state.MyState.IDLE}
	on_floor = root.is_on_floor()
