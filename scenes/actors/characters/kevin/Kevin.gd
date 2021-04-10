tool
extends Actor

const FLOOR_DETECTION_DISTANCE: = 20.0
const ACCELERATION: = 200.0
const FRICTION: = 200.0

onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

func _ready():
	if Engine.editor_hint: return
# warning-ignore:unused_variable
	var vp: Viewport = get_parent().get_viewport()
	
#	animation_state.start("Idle")
	animation_state.start("Walk")

func _physics_process(_delta):
	if Engine.editor_hint: return
	
	var direction: = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		0
	)
	direction = direction.normalized()
	
	if direction.x != 0.0:
		velocity = velocity.move_toward(direction * speed_cap, ACCELERATION * _delta)
		animation_tree.set("parameters/Idle/blend_position", direction)
		animation_tree.set("parameters/Walk/blend_position", direction)
		animation_state.travel("Walk")
	else:
		velocity = velocity.move_toward(Vector2(), FRICTION * _delta)
		animation_tree.set("parameters/Idle/blend_position", direction)
		animation_tree.set("parameters/Walk/blend_position", direction)
		animation_state.travel("Idle")
	
	velocity = move_and_slide_with_snap(
		velocity,
		Vector2.DOWN * FLOOR_DETECTION_DISTANCE,
		Vector2.UP)
