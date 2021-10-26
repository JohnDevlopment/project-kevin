## Game-wide functions and values.
# @name Game
# @singleton
extends Node

## Indicates that a game parameter has changed.
# @arg String  param The parameter that was changed.
# @arg Variant value The value @a param was changed to.
# @desc This signal is emitted when certain functions are called. Which function
#       was called is indicated by @a param.
#
#       Param: dialog_mode@br
#       Type:  bool@br
#       Emitted when @function set_dialog_mode() is called. If true, then
#       dialog mode is active: in this mode, a dialog is in process, so actors
#       should not move or accept input.
#
#       Param: tree_paused@br
#       Type:  bool@br
#       Emitted when @function set_paused() is called.
signal changed_game_param(param, value)

## Collision layer bits
enum CollisionLayer {
	WALLS = 0x01, ## Walls
	PLATFORMS = 0x02, ## Platforms
	PLAYER = 0x04, ## Player foreground collision
	ENEMY = 0x08, ## Enemy foreground collision
	PLAYER_HITBOX = 0x10, ## Player hitbox
	PLAYER_HURTBOX = 0x20, ## Player hurtbox
	ENEMY_HITBOX = 0x40, ## Enemy hitbox
	ENEMY_HURTBOX = 0x80, ## Enemy hurtbox,
	NPC = 0x0100, ## NPC foreground collision
	NPC_DETECTION = 0x0200 ## NPC detection field
}

enum ActorIDS {
	KEVIN,
	DARK_BEAST,
	SIGN,
	
	COUNT
}

var default_kevin_speed := Vector2(85, 275)
var level_size := Vector2(1020, 610)
var dialog_mode := false setget set_dialog_mode
#var global_scale := Vector2.ONE setget set_global_scale

const Scenes := {
	pause_screen = preload("res://scenes/gui/PauseScreen.tscn"),
	damage_strike = preload("res://scenes/vfx/Sprite.tscn"),
	ActorIDS.DARK_BEAST: preload('res://scenes/actors/enemies/DarkBeast.tscn')
}

const Kevin := preload("res://scenes/actors/characters/kevin/Kevin.gd")

func actor_id_to_string(id: int) -> String:
	match id:
		ActorIDS.DARK_BEAST:
			return 'DARK_BEAST'
		ActorIDS.KEVIN:
			return 'KEVIN'
		ActorIDS.SIGN:
			return 'SIGN'
	return ''

func get_player() -> Actor:
	return get_tree().get_nodes_in_group("player")[0]

func go_to_scene(scene: String) -> void:
	get_tree().change_scene(scene)

func has_player() -> bool:
	return get_tree().has_group('player')

func insert_vfx(vfx_name: String, parent: Node, position: Vector2):
	var vfx = Scenes.get(vfx_name)
	assert(vfx is PackedScene, "key \"%s\" is not a PackedScene" % vfx_name)
	if vfx:
		vfx = (vfx as PackedScene).instance()
		parent.add_child(vfx)
		(vfx as Node2D).global_position = position

func is_key_pressed(e: InputEventKey, key: int, echo: bool = false):
	if e.pressed and e.scancode == key:
		if echo:
			return true
		else:
			if not e.echo: return true
	return false

#func set_global_scale(scale := Vector2(1, 1)):
#	var vp := get_tree().root
#	var ct := vp.canvas_transform
#
#	# Create transformation matrix
#	var t := Transform2D.IDENTITY.scaled(scale)
#	t.origin = ct.origin
#
#	vp.set_canvas_transform(t)

## Set or clear dialog mode.
# @desc Depending on whether @a enabled is true or false, this sets or disables
#       dialog mode. In dialog mode, affected nodes stop working and do not
#       accept input from the user, allowing dialog boxes to work without interruption.
#
#       Emits the @code changed_game_param signal.
func set_dialog_mode(enabled: bool):
	dialog_mode = enabled
	emit_signal("changed_game_param", "dialog_mode", enabled)

## Set the pause status of the scene tree.
# @desc Pauses the scene tree if @a paused is true or unpauses it otherwise.
#
#       Emits the @code changed_game_param signal.
func set_paused(paused: bool) -> void:
	get_tree().paused = paused
	emit_signal("changed_game_param", "tree_paused", paused)

func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
