extends State

var on_floor: = false

func _setup():
	var root: Enemy = persistant_state
	
	# Get the direction to player and set speed opposite to them
	var rel_direction: Dictionary = root.direction_to_player()
	root.direction.x = round(rel_direction.direction.x)
	root.velocity = Vector2(-rel_direction.direction.x * 100, -root.speed_cap.y)
	
	root.move_and_collide(Vector2(0, -1))
	
	on_floor = false
	
	root.start_animation_with_blend('Evade', root.direction)

func process_main(_delta):
	if on_floor:
		(user_data.frames as Sprite).frame = 21

func physics_main(delta):
	var root: Enemy = persistant_state
	if on_floor:
		root.velocity.x = move_toward(root.velocity.x, 0, delta * (root.FRICTION))
		if root.velocity.x == 0.0:
			root.start_animation_with_blend('Idle', root.direction)
			return persistant_state.MyState.PROWL
	on_floor = root.is_on_floor()
