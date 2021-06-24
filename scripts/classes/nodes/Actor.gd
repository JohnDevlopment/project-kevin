"""
An actor is derived from a KinematicBody2D, so it is meant to be used for fully-
controlled physics bodies. An actor as a velocity vector to controll its per-frame
movement speed, and a gravity value to control which direction it heads.

"""
tool
class_name Actor, "res://assets/textures/icons/actor.svg"
extends KinematicBody2D

const GRAVITY_STEP: float = 13.4

# Properties #

var speed_cap: = Vector2()

onready var gravity_value: float = ProjectSettings.get_setting("physics/2d/default_gravity")
onready var gravity_vector: Vector2 = ProjectSettings.get_setting("physics/2d/default_gravity_vector")

# Velocity of the actor. Updated by the user.
var velocity: = Vector2.ZERO

# A signal that indicates the actor has collided with something. When emitted,
# includes information about the collision as well as the actor that was
# collided with. The collision info will be a KinematicCollision2D.
signal actor_collided(collision, actor)

# Sets the active/enabled status of the actor. Disables all collision and
# renders the actor invisible. To add custom code to this function,
# define _enable_actor in your code. _enable_actor must accept a boolean value.
func enable_actor(flag: bool) -> void:
	visible = flag
	
	if has_method("_enable_actor"):
		call("_enable_actor", flag)

func enable_collision(flag: bool) -> void:
	if not flag:
		collision_layer = 0
		collision_mask = 0

func _ready():
	if Engine.editor_hint: return

func _enter_tree():
	if not Engine.editor_hint:
		set_meta("collision_layer", collision_layer)
		set_meta("collision_mask", collision_mask)

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
	if Engine.editor_hint: return
	
	velocity.y += GRAVITY_STEP
	if velocity.y > gravity_value:
		velocity.y = gravity_value
