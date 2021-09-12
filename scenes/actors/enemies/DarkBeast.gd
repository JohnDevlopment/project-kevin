tool
extends Enemy

enum MyState {
	IDLE,
	KNOCKBACK,
	ATTACK,
	PROWL,
	EVADE
}

const MAX_SLOPE_ANGLE := deg2rad(45.0)
const FRICTION := 360.0
const ATTACK_RANGE := 70.0

onready var state_machine := $StateMachine
onready var animation_tree := $AnimationTree
onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree['parameters/playback']

var triggered := false

func get_center() -> Vector2:
	var rect: Rect2 = $Frames.get_rect()
	return global_position + (rect.position + rect.size / 2)

func get_cooldown_time() -> float:
	return $CooldownTimer.time_left

func start_animation_with_blend(anim: String, blend) -> void:
	animation_state.travel(anim)
	if blend:
		if blend is Vector2:
			var path := 'parameters/' + anim + '/blend_position'
			animation_tree[path] = blend

# Internal functions

func _physics_process(delta: float) -> void:
	if Engine.editor_hint:
		print('editor physics process')
		set_physics_process(false)
		return
	
	if global_position.y > Game.level_size.y:
		queue_free()
		return
	
	# Evaluate the current state and parse the result
	var result = state_machine.do_physics.call_func(delta)
	
	if result is int:
		var ns: int = result
		if ns >= 0:
			assert(ns < MyState.size(), str("invalid state ", ns))
			state_machine.change_state(ns)
	
	# Update position based on velocity
	velocity.y = move_and_slide(velocity, Vector2.UP, true, 4, MAX_SLOPE_ANGLE, false).y

func _process(delta) -> void:
	if Engine.editor_hint:
		print('editor process')
		set_process(false)
		return
	
	state_machine.do_process.call_func(delta)

func _enter_tree() -> void:
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)

func _ready():
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)
		return
	
	var frames_rect: Rect2 = $Frames.get_rect()
	var udata := {
		animation_player = $AnimationPlayer,
		frames = $Frames,
		hitbox_shape = $Hitbox/CollisionShape2D,
		center = frames_rect.position + frames_rect.size / 2,
		cooldown_timer = $CooldownTimer,
		start_cooldown = false
	}
	
	if Game.has_player():
		var player: Node = Game.get_player()
		assert(player is Game.Kevin)
		player.connect("state_changed", self, "_on_Kevin_state_changed")
		udata["player"] = player
	
	state_machine.set_user_data(udata)
	state_machine.change_state(MyState.IDLE)

# Signal callbacks

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

func _on_Kevin_body_entered(body: Node):
	triggered = true
	set_meta("player", body)
	$TriggerArea.queue_free()

func _on_Kevin_state_changed(_old_state: int, new_state: int) -> void:
	match new_state:
		Game.Kevin.STATE_ATTACK:
			state_machine.state_call("_kevin_attacking")

func _on_CooldownTimer_timeout() -> void:
	state_machine.state_call('_cooldown_timer_timeout')
