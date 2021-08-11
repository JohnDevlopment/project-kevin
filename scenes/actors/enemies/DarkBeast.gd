tool
extends Enemy

enum MyState {
	IDLE,
	KNOCKBACK,
	ATTACK,
	PROWL,
	COUNT
}

const MAX_SLOPE_ANGLE: float = deg2rad(45.0)
const FRICTION: = 360.0

onready var animation_player = $AnimationPlayer
onready var state_machine = $StateMachine
onready var timer1 = $Timer1
onready var frames = $Frames

func _input(event: InputEvent):
	if event is InputEventKey:
		if Game.is_key_pressed(event, KEY_A):
			print("attack!")
			if state_machine.current_state() == MyState.IDLE:
				state_machine.change_state(MyState.ATTACK)

func _physics_process(delta: float):
	if Engine.editor_hint: return
	
	if global_position.y > Game.level_size.y:
		queue_free()
		return
	
	var result = state_machine.do_physics.call_func(delta)
	if result is Dictionary:
		var ns: int = (result as Dictionary).get("state", -1)
		assert(ns < MyState.COUNT, str("invalid state ", ns))
		if ns >= 0:
			state_machine.change_state(ns)
	
	velocity.y = move_and_slide(velocity, Vector2.UP, true, 4,
		MAX_SLOPE_ANGLE, false).y

func _process(delta):
	if Engine.editor_hint: return
	state_machine.do_process.call_func(delta)

func _ready():
	if Engine.editor_hint: return
	state_machine.set_user_data([timer1, animation_player, frames])
	state_machine.change_state(MyState.IDLE)

func _on_damaged(other_stats: Stats) -> void:
	assert(other_stats.has_meta("owner"), str("no \"owner\" meta set for ", other_stats))
	var attacker: Node2D = other_stats.get_meta("owner")
	var dir: Vector2
	if true:
		var temp: = global_position + Vector2(21, 19)
		var center_offset: Vector2 = other_stats.get_meta_or_default("attack_center", Vector2.ZERO)
		dir = temp.direction_to(attacker.global_position + center_offset)
	set_meta("knockback_direction", dir)
	
	if stats.health == 0:
		queue_free()
	else:
		state_machine.change_state(MyState.KNOCKBACK)

# NOTE: animation "IdleLeft" starts timer for 3 seconds
func _on_Timer1_timeout():
	state_machine.state_call("timer1_timeout")

func _choose_animation(anim: String) -> String:
	if direction.x:
		anim += "Left" if direction.x < 0.0 else "Right"
	return anim
