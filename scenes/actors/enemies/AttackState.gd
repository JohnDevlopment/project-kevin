extends State

var on_floor: = false
var next: = false

func _setup():
	(user_data[0] as Timer).start(1)
	on_floor = true
	next = false

func process_main(_delta):
	(user_data[2] as Sprite).frame = 7 if on_floor else 8

func physics_main(delta: float):
	var root: Enemy = persistant_state
	if on_floor and next:
		root.velocity.x = move_toward(root.velocity.x, 0, delta * (root.FRICTION * 1.5))
		if root.velocity.x == 0.0:
			return {state = persistant_state.MyState.IDLE}
	on_floor = root.is_on_floor()

func timer1_timeout() -> void:
	var root: Enemy = persistant_state
	root.velocity = Vector2(100 * root.direction.x, -150)
	next = true
