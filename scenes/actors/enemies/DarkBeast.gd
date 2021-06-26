tool
extends Enemy

onready var animation_player = $AnimationPlayer

var direction: = Vector2.LEFT

func _on_Hurtbox_area_entered(area: Area2D):
	if area.get_collision_layer_bit(Game.CollisionLayer.PLAYER_HITBOX):
		pass
