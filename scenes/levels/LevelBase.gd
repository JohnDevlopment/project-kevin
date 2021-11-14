tool
extends Node2D

export var level_limits := Vector2() setget set_level_limits

var draw_level_limits := false

onready var sprint_meter : TextureProgress

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

func _enter_tree() -> void:
	sprint_meter = $HUD/PlayerHUD/Counters/HBoxContainer/SprintMeter

func _ready() -> void:
	if not Engine.editor_hint:
		Game.connect('changed_game_param', self, '_on_game_param_changed')
		
		Game.set_level_size(level_limits)
		
		# If player exists, 
		if Game.has_player():
			var kevin := Game.get_player()
			kevin.disable_input = true
			yield(get_tree().create_timer(0.5), 'timeout')
			kevin.disable_input = false
		
		# Fade into scene
		Game.set_paused(true)
		TransitionRect.fade_in({duration = 2.0})
		yield(TransitionRect, 'fade_finished')
		Game.set_paused(false)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed('debug'):
			$HUD/DebugConsole.activate()
			get_tree().set_input_as_handled()

func set_draw_level_limits(v: bool) -> void:
	draw_level_limits = v
	update()

func set_level_limits(v: Vector2) -> void:
	level_limits = v.round()
	update()

# Signals

func _on_game_param_changed(_param: String, _value):
	pass

func _on_Kevin_sprint_meter_update_parameters(min_value: float, max_value: float) -> void:
	sprint_meter.min_value = min_value
	sprint_meter.max_value = max_value

func _on_Kevin_sprint_meter_updated(value: float) -> void:
	sprint_meter.value = value
