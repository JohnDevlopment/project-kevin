extends Node

enum CollisionLayer {
	WALLS, PLAYER, ENEMY,
	PLAYER_HITBOX, PLAYER_HURTBOX,
	ENEMY_HITBOX, ENEMY_HURTBOX
}

var globals: = {
	default_kevin_speed = Vector2(85, 275)
}
