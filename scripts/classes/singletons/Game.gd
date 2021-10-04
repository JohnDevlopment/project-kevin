extends Node

# TODO: add documentation

signal changed_game_param(param, value)

enum CollisionLayer {
	WALLS,
	PLATFORMS,
	PLAYER,
	ENEMY,
	PLAYER_HITBOX,
	PLAYER_HURTBOX,
	ENEMY_HITBOX,
	ENEMY_HURTBOX
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
var global_scale := Vector2.ONE setget set_global_scale

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

func set_global_scale(scale := Vector2(1, 1)):
	var vp := get_tree().root
	var ct := vp.canvas_transform
	
	# Create transformation matrix
	var t := Transform2D.IDENTITY.scaled(scale)
	t.origin = ct.origin
	
	vp.set_canvas_transform(t)

func set_dialog_mode(enabled: bool):
	dialog_mode = enabled
	emit_signal("changed_game_param", "dialog_mode", enabled)

func set_paused(paused: bool) -> void:
	get_tree().paused = paused
	emit_signal("changed_game_param", "tree_paused", paused)

func _ready() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
