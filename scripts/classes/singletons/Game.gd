extends Node

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

var globals: = {
	default_kevin_speed = Vector2(85, 275)
}

var level_size: = Vector2(1020, 610)

const VFX = {
	"damage_strike": preload("res://scenes/vfx/Sprite.tscn")
}

func insert_vfx(vfx_name: String, parent: Node, position: Vector2):
	var vfx = VFX.get(vfx_name)
	assert(vfx is PackedScene, "key \"%s\" is not a PackedScene" % vfx_name)
	if vfx:
		vfx = (vfx as PackedScene).instance()
		parent.add_child(vfx)
		(vfx as Node2D).global_position = position

func get_rect_from_shape(shape: Shape2D):
	if shape is RectangleShape2D:
		return Rect2(-shape.extents, shape.extents * 2)

func get_shape_from_id(area, shape: int):
	var area_id = area

	if area is int:
		area = instance_from_id(area_id)
	elif area is Area2D:
		area_id = (area as Object).get_instance_id()
	else:
		push_error("area parameter is invalid, must be an integer or Area2D")
		return

	var _owner = area.shape_find_owner(shape)
	return area.shape_owner_get_shape(_owner, shape)
