extends State

var on_floor: = false

func _setup():
	var root: Enemy = persistant_state
	
	# Updates the on_* flags
	root.move_and_slide(Vector2(0, -1), Vector2.UP)
	
	var dir: float = 0.0
	if true:
		var temp: Vector2 = root.get_meta_or_default("knockback_direction", root.direction)
		dir = round(temp.x)
	
	root.direction.x = dir
	root.velocity = Vector2(-dir * 100, -root.speed_cap.y)
	on_floor = false
	
	root.start_animation_with_blend('Knockback', root.direction)

func process_main(_delta):
	if on_floor:
		(user_data.frames as Sprite).frame = 9
	else:
		(user_data.frames as Sprite).frame = 8

func physics_main(delta):
	var root: Enemy = persistant_state
	if on_floor:
		root.velocity.x = move_toward(root.velocity.x, 0, delta * (root.FRICTION * 1.5))
		if root.velocity.x == 0.0:
			user_data.start_cooldown = true
			return persistant_state.MyState.IDLE
	on_floor = root.is_on_floor()

#func cleanup():
#	persistant_state.velocity.x = 0
