tool
extends Node2D

export var level_limits := Vector2() setget set_level_limits

var draw_level_limits := false

func _get(property: String):
	match property:
		'editor/draw_level_limits':
			return draw_level_limits

func _set(property: String, value) -> bool:
	match property:
		'editor/draw_level_limits':
			set_draw_level_limits(value)
		_:
			return false
	
	return true

func _get_property_list() -> Array:
	return [
		{
			name = 'editor/draw_level_limits',
			type = TYPE_BOOL,
			usage = PROPERTY_USAGE_DEFAULT
		}
	]

func _draw() -> void:
	if Engine.editor_hint:
		if draw_level_limits and level_limits != Vector2.ZERO:
			var drawing_rect := Rect2(Vector2(), level_limits * Game.TILE_SIZE)
			draw_rect(drawing_rect, Color.black, false)

func _ready() -> void:
	if not Engine.editor_hint:
		Game.connect('changed_game_param', self, '_on_game_param_changed')
		
		Game.set_level_size(level_limits)
		
		# If player exists, 
		if Game.has_player():
			var kevin := Game.get_player()
			kevin.disable_input = true
			yield(get_tree().create_timer(1), 'timeout')
			kevin.disable_input = false
		
		# Fade into scene
		Game.set_paused(true)
		TransitionRect.fade_in({duration = 2.0})
		yield(TransitionRect, 'fade_finished')
		Game.set_paused(false)

func set_draw_level_limits(v: bool) -> void:
	draw_level_limits = v
	update()

func set_level_limits(v: Vector2) -> void:
	level_limits = v.round()
	update()

# Signals

func _on_game_param_changed(_param: String, _value):
	pass
