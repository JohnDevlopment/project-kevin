extends State

var on_floor: = false
var next: = false

func _setup():
	on_floor = true
	next = false
	persistant_state.start_animation_with_blend('Attack', persistant_state.direction)
	persistant_state.velocity.x = 0.0

func process_main(_delta):
	if on_floor and next:
		(user_data.frames as Sprite).frame = 10

func physics_main(delta: float):
	var root: Enemy = persistant_state
	if on_floor and next:
		root.velocity.x = move_toward(root.velocity.x, 0, delta * (root.FRICTION * 1.5))
		if root.velocity.x == 0.0:
			user_data.start_cooldown = true
			return persistant_state.MyState.EVADE
			
	on_floor = root.is_on_floor()

func attack() -> void:
	var root: Enemy = persistant_state
	root.velocity = Vector2(200 * root.direction.x, -150)
	next = true
	on_floor = false
	root.move_and_collide(Vector2.UP)
