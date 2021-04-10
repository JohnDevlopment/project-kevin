tool
class_name GameObject
extends Area2D

export(Vector2) var snap = Vector2(16, 16) setget set_snap

func set_snap(vec: Vector2):
	if Engine.is_editor_hint():
		if vec.x <= 0: vec.x = 16
		if vec.y <= 0: vec.y = 16
		snap = vec

func _ready():
	set_notify_transform(true)

#func snap_vector(vec: Vector2):
#	var modx = fmod(vec.x, snap.x)
#	vec.x = round(vec.x - modx)
#	var mody = fmod(vec.y, snap.y)
#	vec.y = round(vec.y - mody)
#	return vec

func _notification(what):
	if not Engine.is_editor_hint(): return
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		position = position.snapped(snap)
