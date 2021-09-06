# Extends the functionality of KinematicBody2D with gravity and a vector speed and velocity.
# By default, the physics process handles gravity with linear interpolation.
tool
class_name Actor, "res://assets/textures/icons/Actor.svg"
extends KinematicBody2D

const GRAVITY_STEP: float = 13.4

# Properties #

var speed_cap: = Vector2()
var disabled: = false setget set_disabled

onready var gravity_value: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Velocity of the actor. Updated by the user.
var velocity: = Vector2.ZERO

# Sets the active/enabled status of the actor. Disables all collision and
# renders the actor invisible. To add custom code to this function,
# define _enable_actor in your code. _enable_actor must accept a boolean value.
func enable_actor(flag: bool) -> void:
	visible = flag
	enable_collision(flag)
	
	if has_method("_enable_actor"):
		call("_enable_actor", flag)

# Enables or disables collision by modifying the collision layer and mask properties.
func enable_collision(flag: bool) -> void:
	if not flag:
		collision_layer = 0
		collision_mask = 0
	else:
		collision_layer = get_meta('collision_layer')
		collision_mask = get_meta('collision_mask')

# Override this function to return the global position of the center of the actor.
func get_center() -> Vector2: return Vector2()

# Setter function for property 'disabled'
func set_disabled(d: bool) -> void:
	disabled = d
	enable_actor(disabled)

func _ready() -> void:
	if Engine.editor_hint:
		set_physics_process(false)
		set_process(false)

func _enter_tree():
	if Engine.editor_hint:
		set_physics_process(false)
		set_process(false)
		return
	set_meta("collision_layer", collision_layer)
	set_meta("collision_mask", collision_mask)

func _to_string(): return "[Actor:%d]" % get_instance_id()

func _set(property, value):
	match property:
		"speed_cap":
			speed_cap = value
		"disabled":
			set_disabled(value)
		_:
			return false
	return true

func _get(property):
	match property:
		"speed_cap":
			return speed_cap
		"disabled":
			return disabled

func _get_property_list():
	return [
		{
			name = "Actor",
			type = TYPE_NIL,
			usage = PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE
		},
		{
			name = "speed_cap",
			type = TYPE_VECTOR2,
			usage = PROPERTY_USAGE_DEFAULT
		},
		{
			name = "disabled",
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		}
	]

func _physics_process(_delta):
	velocity.y = move_toward(velocity.y, gravity_value, GRAVITY_STEP)
#	velocity.y += GRAVITY_STEP
#	if velocity.y > gravity_value:
#		velocity.y = gravity_value
