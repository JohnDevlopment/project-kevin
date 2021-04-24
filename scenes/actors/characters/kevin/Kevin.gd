tool
extends Actor

const FLOOR_DETECTION_DISTANCE: = 20.0
const ACCELERATION: = 200.0
const FRICTION: = 350.0

onready var state_machine = $StateMachine
var on_ground: = false
var jump_once: = false

func _ready():
	if Engine.editor_hint: return
	state_machine.change_state("Normal")

func _physics_process(_delta):
	if Engine.editor_hint: return
	state_machine.call_physics_main(_delta)
	velocity = move_and_slide(velocity, Vector2.UP)

func _unhandled_key_input(event):
	if event.is_action_pressed("jump"):
		on_ground = is_on_floor()
		if on_ground:
			jump_once = true
			set_deferred("jump_once", false)

func calculate_move_velocity(delta: float):
	var direction: = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		0
	)
	direction = direction.normalized()
	
	if direction.x != 0.0:
		velocity = velocity.move_toward(direction * speed_cap, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2(), FRICTION * delta)
	
	return {direction = direction, velocity = velocity}
