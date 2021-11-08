extends Node2D

# CONNECT_ONESHOT = 1

func _array_get(a: Array, idx: int, default = null):
	assert(idx >= 0, "no negative values!")
	if idx < a.size():
		return a[idx]
	return default

func _ready() -> void:
	# fade into scene
	Game.set_paused(true)
	TransitionRect.fade_in()
	yield(TransitionRect, 'fade_finished')
	BackgroundMusic.play_music("menu")
	Game.set_paused(false)

func _on_music_finished(button: Button) -> void:
	button.disabled = true

func _to_scene(music_fade: float, fade_duration: float, next_scene: String):
	Game.set_paused(true)
	BackgroundMusic.fade_out(music_fade)
	TransitionRect.fade_out({duration = fade_duration})
	yield(TransitionRect, 'fade_finished')
	Game.set_paused(false)
	Game.go_to_scene(next_scene)

func _on_button_pressed(tag: String):
	match tag:
		"ctest":
			_to_scene(4.0, 4.0, "res://CharacterTest.tscn")
		"dtest":
			_to_scene(4, 4, 'res://scenes/DialogTest.tscn')
