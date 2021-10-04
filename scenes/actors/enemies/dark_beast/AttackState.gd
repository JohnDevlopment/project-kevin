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
			var distance: Vector2
			if true:
				var player = Game.get_player()
				distance = (root.get_center() - player.get_center()).abs()
			
			# Don't evade if far away
			if distance.x < 90.0:
				user_data.start_cooldown = true
				return persistant_state.MyState.EVADE
			root.direction.x = -root.direction.x
			return persistant_state.MyState.PROWL
			
	on_floor = root.is_on_floor()

func attack() -> void:
	var root: Enemy = persistant_state
	root.velocity = Vector2(200 * root.direction.x, -150)
	next = true
	on_floor = false
	root.move_and_slide(Vector2.UP, Vector2.UP)

#func get_distance():
#	var root: Enemy = persistant_state
#	var player: Game.Kevin = Game.get_player()
#
#	return (root.get_center() - player.get_center()).abs()
