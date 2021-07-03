tool
extends Actor

signal sprint_meter_updated(value)
signal sprint_meter_update_parameters(min_value, max_value)

# temp signal, will delete later
signal attack_anim_hit_wall

# State constants
const STATE_NORMAL = 0
const STATE_SPRINT = 1
const STATE_AIR = 2
const STATE_ATTACK = 3

const FLOOR_DETECTION_DISTANCE: = 20.0
const ACCELERATION: = 200.0
const FRICTION: = 360.0
const MAX_SLOPE_ANGLE: float = deg2rad(45.0)
const SPRINT_METER_CAP: float = 100.0
const AIR_FRAMES: = PoolIntArray([
	18, 19, 20, 21,
	22, 23, 24, 25,
	26, 27, 28, 29,
	
	30, 31, 32, 33,
	34, 35, 36, 37,
	38, 39, 40, 41
])

export var disable_input: bool = false
export(Resource) var stats

onready var state_functions: = [
	funcref(self, "NormalState"),
	funcref(self, "SprintState"),
	funcref(self, "AirState"),
	funcref(self, "AttackState")
]

onready var state_process_functions: = [
	funcref(self, "NormalSprintState_Process"),
	funcref(self, "NormalSprintState_Process"),
	funcref(self, "JumpState_Process"),
	funcref(self, "DummyState")
]

onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var frames = $Frames
var moving: = false
var input_vector: = Vector2.RIGHT
var sprinting: = false
var recovering: = false
var direction: = Vector2.RIGHT

var _current_state: = 0
var _current_anim_state: = ""
var _sprint_meter: = SPRINT_METER_CAP
var _jump_once: = false
var _air_frame_offset: = 0

func _ready():
	if Engine.editor_hint: return
	
	emit_signal("sprint_meter_update_parameters", 0, 100)
	emit_signal("sprint_meter_updated", 100)
	
	assert(stats, "'stats' object is empty")
	(stats as Stats).init_stats(self)

func _process(delta: float):
	if Engine.editor_hint: return
	
	_current_anim_state = animation_state.get_current_node()
	state_process_functions[_current_state].call_func(delta)

func _physics_process(_delta):
	if Engine.editor_hint: return
	
	# Get input at beginning of frame.
	if disable_input:
		input_vector.x = 0.0
		sprinting = false
	else:
		input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		input_vector = input_vector.normalized()
		sprinting = Input.is_action_pressed("dash")
	
	if input_vector.x != 0.0 and _current_state != STATE_AIR:
		_air_frame_offset = 0 if input_vector.x > 0.0 else 12
	
	# Set the direction player is facing.
	if input_vector.x != 0.0:
		direction = input_vector
	
	state_functions[_current_state].call_func(_delta)
	
	var snap_vector: Vector2 = Vector2.DOWN * 20 if not _jump_once else Vector2()
	velocity.y = \
		move_and_slide_with_snap(velocity, snap_vector, Vector2.UP, true, 4,
			MAX_SLOPE_ANGLE, false).y

func _unhandled_key_input(event):
	if disable_input: return
	if event.is_action_pressed("jump"):
		if is_on_floor():
			_jump_once = true
			set_deferred("_jump_once", false)
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("action"):
		if is_on_floor():
			# TODO: Is this code right? The animation state is set
			#       inside of change_state when initializing the attack state.
			change_state(STATE_ATTACK)
		get_tree().set_input_as_handled()

func update_velocity(goal_speed: Vector2, friction: float, acceleration: float):
	if moving:
		velocity.x = move_toward(velocity.x, goal_speed.x, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction)
		if abs(velocity.x) <= 0.01:
			velocity.x = 0.0

func set_sprint_meter(value: float) -> void:
	if Engine.editor_hint: return
	
	var old_sprint_meter: float = _sprint_meter
	_sprint_meter = value
	
	if old_sprint_meter != _sprint_meter:
		if _sprint_meter == 0.0:
			$RecoveryTimer.start()
			recovering = true
			speed_cap /= 2
		emit_signal("sprint_meter_updated", _sprint_meter)

func change_state(next_state: int) -> void:
	var prev_state: = _current_state
	_current_state = next_state
	
	# Cleanup the current state.
	match prev_state:
		STATE_AIR:
			velocity.x = 0.0
			moving = true
	
	# Initialize the next state.
	match next_state:
		STATE_NORMAL:
			animation_tree.set("parameters/conditions/idle", !moving)
			animation_state.travel("Run" if moving else "Idle")
		STATE_SPRINT:
			moving = false
		STATE_AIR:
			moving = false
			animation_tree.set("parameters/conditions/idle", false)
			animation_tree.set("parameters/Idle/blend_position", direction)
			animation_state.travel("Idle")
		STATE_ATTACK:
			moving = false
			animation_state.travel("Attack")
			animation_tree.set("parameters/Attack/blend_position", direction)

func get_air_frame() -> int:
	var idx = \
		range_lerp(velocity.y, -speed_cap.y, gravity_value, 0, AIR_FRAMES.size() / 2)
	idx = int(clamp(idx, 0, AIR_FRAMES.size() / 2 - 1))
	
	return AIR_FRAMES[idx + _air_frame_offset]

# States (Physics)

func NormalState(delta: float) -> void:
	moving = input_vector.x != 0.0
	
	if recovering:
		set_sprint_meter(move_toward(_sprint_meter, SPRINT_METER_CAP, 10 * delta))
	else:
		if Input.is_action_just_pressed("dash") and moving:
			change_state(STATE_SPRINT)
			return
		
		set_sprint_meter(move_toward(_sprint_meter, SPRINT_METER_CAP, 25 * delta))
	
	update_velocity(speed_cap * input_vector.x, FRICTION * delta, ACCELERATION * delta)
	
	if _jump_once:
		velocity.y = -speed_cap.y
		global_position.y -= 2
		change_state(STATE_AIR)
		return
	elif not is_on_floor():
		change_state(STATE_AIR)
		return

func SprintState(delta: float) -> void:
	moving = input_vector.x != 0.0
	
	if not Input.is_action_pressed("dash") or not moving:
		change_state(STATE_NORMAL)
		return
	
	set_sprint_meter(move_toward(_sprint_meter, 0.0, 32 * delta))
	if _sprint_meter == 0.0:
		change_state(STATE_NORMAL)
		return
	
	update_velocity(speed_cap * 1.5 * input_vector.x,
		(FRICTION - 30.0) * delta, (ACCELERATION - 50.0) * delta)
	
	if _jump_once:
		velocity.y = -speed_cap.y * 1.2
		global_position.y -= 2
		change_state(STATE_AIR)
		return
	elif not is_on_floor():
		change_state(STATE_AIR)
		return

func AirState(_delta: float):
	if is_on_floor():
		change_state(STATE_NORMAL)
		return

func AttackState(_delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, FRICTION * _delta)

func _on_RecoveryTimer_timeout():
	if Engine.editor_hint: return
	speed_cap *= 2
	recovering = false

# States (Process)

func NormalSprintState_Process(_delta: float) -> void:
	if moving:
		animation_tree.set("parameters/Idle/blend_position", direction)
		animation_tree.set("parameters/Run/blend_position", direction)
		
		if _current_anim_state == "Idle":
			animation_state.travel("Run")
			animation_tree.set("parameters/conditions/idle", false)
	else:
		if _current_anim_state == "Run" and velocity.x == 0.0:
			animation_tree.set("parameters/conditions/idle", true)

func JumpState_Process(_delta: float) -> void:
	frames.frame = get_air_frame()

func DummyState(_delta: float) -> void:
	pass

func _on_Hitbox_body_entered(body: Node):
	if body is TileMap:
		if (body as TileMap).get_collision_layer_bit(Game.CollisionLayer.WALLS):
			velocity.x = -100.0 * direction.x
			emit_signal("attack_anim_hit_wall")

func _on_hit_enemy_hurtbox(area: Area2D):
	var parent: Enemy = area.get_parent()
	parent.call_deferred("decide_damage", stats)
