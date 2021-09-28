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
		set_physics_process(false)
		return
	
	if global_position.y > Game.level_size.y:
		queue_free()
		return
	
	# Evaluate the current state and parse the result
	var result = state_machine.state_physics(delta)
	
	if result is int:
		var ns: int = result
		if ns >= 0:
			assert(ns < MyState.size(), str("invalid state ", ns))
			state_machine.change_state(ns)
	
	if not state_machine.paused:
		velocity.y = move_and_slide(velocity, Vector2.UP, true, 4, MAX_SLOPE_ANGLE, false).y

func _process(delta: float) -> void:
	if Engine.editor_hint:
		set_process(false)
		return
	
	state_machine.state_physics(delta)

func _enable_actor(flag: bool) -> void:
	if !flag:
		enable_collision(true)
		visible = true
	state_machine.paused = !flag

func _enter_tree() -> void:
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)

func _ready():
	if Engine.editor_hint:
		set_process(false)
		set_physics_process(false)
		return
	
	if Game.has_player():
		var distnot: DistanceNotifier = $DistanceToPlayer
		#distnot.component = DistanceNotifier.Y_COMPONENT
		#distnot.threshold = Vector2(0, 90.0)
		distnot.set_other_node(Game.get_player().get_node(@"CenterOffset"))
	
	var frames_rect: Rect2 = $Frames.get_rect()
	var udata := {
		animation_player = $AnimationPlayer,
		frames = $Frames,
		hitbox_shape = $Hitbox/CollisionShape2D,
		center = frames_rect.position + frames_rect.size / 2,
		cooldown_timer = $CooldownTimer,
		start_cooldown = false,
		distance_notifier = $DistanceToPlayer
	}
	
	if Game.has_player():
		var player: Node = Game.get_player()
		assert(player is Game.Kevin)
		player.connect("state_changed", self, "_on_Kevin_state_changed")
		udata["player"] = player
	
	Game.connect('changed_game_param', self, '_on_game_param_changed', [], CONNECT_DEFERRED)
	
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
		invincibility_timer.start()

func _on_Kevin_body_entered(body: Node):
	triggered = true
	set_meta("player", body)
	$TriggerArea.queue_free()
#	$DistanceToPlayer.connect('entered_range', self, '_on_PlayerTooHigh_entered_range')
#	$DistanceToPlayer.connect('exited_range', self, '_on_PlayerTooHigh_exited_range')

func _on_Kevin_state_changed(_old_state: int, new_state: int) -> void:
	match new_state:
		Game.Kevin.STATE_ATTACK:
			state_machine.state_call("_kevin_attacking")
		Game.Kevin.STATE_AIR:
			state_machine.state_call("_kevin_jumping")

func _on_CooldownTimer_timeout() -> void:
	state_machine.state_call('_cooldown_timer_timeout')

func _on_game_param_changed(param: String, value) -> void:
	if param == 'dialog_mode':
		enable_actor(! (value as bool))

#func _on_PlayerTooHigh_exited_range(_node) -> void:
#	triggered = false
#	state_machine.change_state(MyState.IDLE)

#func _on_PlayerTooHigh_entered_range(_node) -> void:
#	triggered = true
#	state_machine.change_state(MyState.IDLE)
