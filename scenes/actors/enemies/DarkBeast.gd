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

onready var state_machine = $StateMachine

var triggered := false

func get_center() -> Vector2:
	var center = $Frames.get_rect()
	center = (center as Rect2).position + (center as Rect2).size / 2
	return global_position + center

func _physics_process(delta: float):
	if Engine.editor_hint: return
	
	if global_position.y > Game.level_size.y:
		queue_free()
		return
	
	# Evaluate the current state and parse the result
	var result = state_machine.do_physics.call_func(delta)
	
	if result is int:
		var ns: int = result
		if ns >= 0:
			assert(ns < MyState.COUNT, str("invalid state ", ns))
			state_machine.change_state(ns)
	
	# Update position based on velocity
	velocity.y = move_and_slide(velocity, Vector2.UP, true, 4,
		MAX_SLOPE_ANGLE, false).y

func _process(delta):
	if Engine.editor_hint: return
	state_machine.do_process.call_func(delta)

func _ready():
	if Engine.editor_hint: return
	
	var center = $Frames.get_rect()
	center = (center as Rect2).position + (center as Rect2).size / 2
	var player = Game.get_player()
	if player:
		player.connect("state_changed", self, "_on_Kevin_state_changed")
	
	var udata := {
		timer = $Timer1,
		animation_player = $AnimationPlayer,
		frames = $Frames,
		center = center
	}
	if player is Game.Classes.Kevin:
		udata["player"] = player
	
	state_machine.set_user_data(udata)
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

func _on_Timer1_timeout():
	state_machine.state_call("timer1_timeout")

func _choose_animation(anim: String) -> String:
	if direction.x:
		anim += "Left" if direction.x < 0.0 else "Right"
	return anim

func _on_Kevin_body_entered(body: Node):
	triggered = true
	set_meta("player", body)
	$TriggerArea.queue_free()

# Note: connected to Kevin's "state_changed" signal in _ready
func _on_Kevin_state_changed(old_state, new_state) -> void:
	state_machine.state_call("_kevin_state_changed", [old_state, new_state])
