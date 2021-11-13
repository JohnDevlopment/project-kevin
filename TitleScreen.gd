extends Node2D

var GoToVillage: Button

func _array_get(a: Array, idx: int, default = null):
	assert(idx >= 0, "no negative values!")
	if idx < a.size():
		return a[idx]
	return default

func _ready() -> void:
	NodeMapper.map_nodes(self)
	
	Game.connect('changed_game_param', self, '_on_game_param_changed')
	
	# fade into scene
	Game.set_paused(true)
	TransitionRect.fade_in()
	yield(TransitionRect, 'fade_finished')
	BackgroundMusic.play_music("menu")
	Game.set_paused(false)

func _to_scene(music_fade: float, fade_duration: float, next_scene: String):
	Game.set_paused(true)
	BackgroundMusic.fade_out(music_fade)
	TransitionRect.fade_out({duration = fade_duration})
	yield(TransitionRect, 'fade_finished')
	Game.set_paused(false)
	Game.go_to_scene(next_scene)

func _on_button_pressed(tag: String):
	match tag:
		"village":
			_to_scene(4, 4, 'res://scenes/levels/Village.tscn')
		"dtest":
			pass

func _on_game_param_changed(param: String, value) -> void:
	match param:
		'tree_paused':
			print("tree is %s" % ('paused' if value else 'not paused'))
		'changing_scene':
			print("Changing scene to '%s' from current scene '%s'" % [value, get_tree().current_scene])
