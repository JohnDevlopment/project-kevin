## Kinematic Actor type
# @desc  Extends the functionality of KinematicBody2D with gravity and a vector speed and velocity.
#        By default, the physics process handles gravity with linear interpolation.
tool
class_name Actor, "res://assets/textures/icons/Actor.svg"
extends KinematicBody2D

const GRAVITY_STEP: float = 13.4

## Speed cap of the actor
# @export
var speed_cap: = Vector2()

## Terminal Y velocity based on gravity
onready var gravity_value: float = ProjectSettings.get_setting("physics/2d/default_gravity")

## Velocity of the actor, manually updated
var velocity: = Vector2.ZERO

# Sets the active/enabled status of the actor. Disables all collision and
# renders the actor invisible. To add custom code to this function,
# define _enable_actor in your code. _enable_actor must accept a boolean value.

## Enable/disable the @class Actor
# @arg{bool}  True for enable, false for disable
# @desc       Call this function to enable or disable the actor.
#             Affects the visibility and collision of the actor.
# @note       This function calls @function _enable_actor if it is overridden
#             in the instance.
func enable_actor(flag: bool) -> void:
	visible = flag
	enable_collision(flag)
	
	if has_method("_enable_actor"):
		call("_enable_actor", flag)

## Enable/disabled collision
# @arg{bool}  True for enable, false for disable
func enable_collision(flag: bool) -> void:
	if not flag:
		collision_layer = 0
		collision_mask = 0
	else:
		collision_layer = get_meta('collision_layer')
		collision_mask = get_meta('collision_mask')

## Returns the center of the actor
# @virtual
# @return   The center of the actor as a @type Vector2
# @note     Override this function to return the global position of the center of the actor.
func get_center() -> Vector2: return Vector2()

func _ready() -> void:
	if Engine.editor_hint:
		set_physics_process(false)
		set_process(false)

func _init() -> void:
	set_meta("collision_layer", collision_layer)
	set_meta("collision_mask", collision_mask)

func _enter_tree() -> void:
	if Engine.editor_hint:
		set_physics_process(false)
		set_process(false)

func _to_string(): return "[Actor:%d]" % get_instance_id()

func _set(property, value):
	match property:
		"speed_cap":
			speed_cap = value
		_:
			return false
	return true

func _get(property):
	match property:
		"speed_cap":
			return speed_cap

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
