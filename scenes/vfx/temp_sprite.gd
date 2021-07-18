extends AnimatedSprite

func _ready():
	play()

func _on_temp_slash_animation_finished():
	queue_free()
