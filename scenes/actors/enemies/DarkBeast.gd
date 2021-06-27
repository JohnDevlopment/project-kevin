tool
extends Enemy

onready var animation_player = $AnimationPlayer

var direction: = Vector2.LEFT

func _do_damage(other_stats: Stats) -> void:
	if stats.health == 0:
		queue_free()
