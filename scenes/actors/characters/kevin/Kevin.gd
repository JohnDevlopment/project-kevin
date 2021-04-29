tool
extends Actor

const FLOOR_DETECTION_DISTANCE: = 20.0
const ACCELERATION: = 200.0
const FRICTION: = 360.0
const MAX_SLOPE_ANGLE: float = deg2rad(45.0)

onready var state_machine = $StateMachine
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
var jump_once: = false
var moving: = false
var was_moving: = false
var input_vector: = Vector2(1, 0)
var sprinting: = false

func _ready():
	if Engine.editor_hint: return
	state_machine.change_state("Normal")

func _process(_delta):
	if moving:
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		if not was_moving:
			animation_tree.set("parameters/conditions/stopped", false)
			animation_state.travel("Run")

func _physics_process(_delta):
	if Engine.editor_hint: return
	state_machine.call_physics_main(_delta)
	velocity.y = move_and_slide(velocity, Vector2.UP, true, 4, MAX_SLOPE_ANGLE, false).y

func _unhandled_key_input(event):
	if event.is_action_pressed("jump"):
		if is_on_floor():
			jump_once = true
			set_deferred("jump_once", false)
		get_tree().set_input_as_handled()

func get_air_frame():
	var air_index = range_lerp(velocity.y, -speed_cap.y, gravity_value, 0, 8)
	return int(round(air_index))

func calculate_move_velocity(delta: float):
	input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		0
	).normalized()
	
	var speed_vec: Vector2 = speed_cap
	
	was_moving = moving
	moving = input_vector.x != 0.0
	
	if moving:
#		velocity = velocity.move_toward(input_vector * lin_vel, ACCELERATION * delta)
		velocity.x = move_toward(velocity.x, input_vector.x * speed_vec.x, ACCELERATION * delta)
	else:
#		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
		if abs(velocity.x) <= 0.01:
			velocity.x = 0.0
			animation_tree.set("parameters/conditions/stopped", true)
	
	return {direction = input_vector, velocity = velocity}

func inc_to(from: float, to: float, delta: float, epsilon: float = 0.1):
	return to if abs(to - from) <= epsilon else from + sign(to - from) * delta
