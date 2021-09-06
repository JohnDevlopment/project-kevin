extends Node2D

# CONNECT_ONESHOT = 1

const BUTTON_COMMANDS := [
	["Start Character Test", "ctest_start"],
	["Use Vector Calculator", "vec_calc"],
	["Play Music", "music_start", 1],
	["Fade Music Out", "music_fade", 1]
]

func _array_get(a: Array, idx: int, default = null):
	assert(idx >= 0, "no negative values!")
	if idx < a.size():
		return a[idx]
	return default

func _ready() -> void:
	var box: Node = $CanvasLayer/MarginContainer/VBoxContainer
	for node in box.get_children():
		node.queue_free()
	
	for command in BUTTON_COMMANDS:
		var btn_name: String = command[0]
		var btn_tag: String = command[1]
		var bind_flags: int = 0
		var button := Button.new()
		bind_flags = _array_get(command, 2, 0)
		button.text = btn_name
		button.name = btn_tag
		box.add_child(button, true)
		button.connect("pressed", self, "_on_button_pressed", [btn_tag], bind_flags)
	
	var button = get_node(@"CanvasLayer/MarginContainer/VBoxContainer/music_fade")
	button.disabled = true

func _on_button_pressed(tag: String):
	match tag:
		"music_start":
			BackgroundMusic.play_music("menu")
			var button
			button = get_node(@"CanvasLayer/MarginContainer/VBoxContainer/music_start")
			button.disabled = true
			button = get_node(@"CanvasLayer/MarginContainer/VBoxContainer/music_fade")
			button.disabled = false
			yield(BackgroundMusic, 'finished')
			button.disabled = true
		"music_fade":
			BackgroundMusic.fade_out(3.0)
			var button = get_node(@"CanvasLayer/MarginContainer/VBoxContainer/music_fade")
			button.disabled = true
		"ctest_start":
#			BackgroundMusic.stop()
			BackgroundMusic.fade_out(3.0)
			get_tree().change_scene("res://CharacterTest.tscn")
		"vec_calc":
			BackgroundMusic.fade_out(6.0)
			get_tree().change_scene("res://scenes/gui/VectorCalculator.tscn")
