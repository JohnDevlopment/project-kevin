## Singleton used to control fade in and fade out effects.
extends CanvasLayer

## @name TransitionRect

## Signifies that the fade is finished
signal fade_finished(type)

## The default duration of a fade
const DEFAULT_DURATION := 1.0

onready var tween = $Tween

# element: [String scene, bool deferred]
var _queued_scene := []

# element: [String method, Dictionary options]
var _queued_fade := []

func _ready() -> void:
	var screen_size := Vector2(
		ProjectSettings.get("display/window/size/width"),
		ProjectSettings.get("display/window/size/height")
	)
	set_meta('screen_size', screen_size)
	set_meta('current_fade', '...')

## Start a fade-in effect.
# @desc  This function interpolates the alpha value of a black rectangle from
#        one to zero. Certain aspects of the fade, such as fade-time and the
#        initial value, can be controlled via @a options.
#
#        @a options is a dictionary that contains various parameters for the fade:
#        the key @i initial_value is used to specify the initial alpha value
#        at the start of the fade, and @i duration is used to specify how long
#        the fade lasts in seconds.
#
#        @i duration must be a positive number greater than zero in order to be read.
#        If this parameter is not provided or is invalid, it defaults to
#        @constant DEFAULT_DURATION.
#
#        The option @i initial_value defaults to 1.0 unless it is specified by
#        the user. For it to be valid, the initial value must be in the range [0.01, 1.0].
func fade_in(options: Dictionary = {}) -> void:
	if tween.is_active(): return
	
	# duration of the fade
	var duration := DEFAULT_DURATION
	if 'duration' in options:
		# only set duration if parameter is over zero
		var temp: float = options['duration']
		if temp > 0.0:
			duration = temp
	
	# initial value
	var initial_value := 1.0
	if 'initial_value' in options:
		var temp: float = options['initial_value']
		if Math.is_in_range(temp, 0.01, 1.0):
			initial_value = temp
	
	print("interpolate alpha between %f and %f in %f seconds"
		% [initial_value, 0.0, duration])
	
	# start tween
	tween.interpolate_property($ColorRect, @"self_modulate:a",
		initial_value, 0.0, duration, Tween.TRANS_LINEAR)
	tween.start()
	
	set_meta('current_fade', 'in') # fade type

## Start a fade out effect.
# @desc  This function causes a fade-out effect by interpolating the alpha value
#        of a black rectangle covering the screen, from zero to one.
#
#        @a options is a dictionary that contains various parameters for the fade:
#        the key @i initial_value is used to specify the initial alpha value
#        at the start of the fade, and @i duration is used to specify how long
#        the fade lasts in seconds.
#
#        @i duration must be a positive number greater than zero in order to be read.
#        If this parameter is not provided or is invalid, it defaults to
#        @constant DEFAULT_DURATION.
#
#        The option @i initial_value defaults to zero unless it is specified by
#        the user. For it to be valid, the initial value must be in the range [0.0, 0.99].
func fade_out(options: Dictionary = {}) -> void:
	if tween.is_active(): return
	
	# duration of the fade
	var duration := DEFAULT_DURATION
	if 'duration' in options:
		# only set duration if parameter is over zero
		var temp: float = options['duration']
		if temp > 0.0:
			duration = temp
	
	# initial value
	var initial_value: float = $ColorRect.self_modulate.a
	if initial_value >= 1.0:
		initial_value = 0.0
	
	# option overrides initial_value
	if 'initial_value' in options:
		var temp: float = options['initial_value']
		if Math.is_in_range(temp, 0.00, 0.99):
			initial_value = temp
	
	print("interpolate alpha between %f and %f in %f seconds"
		% [initial_value, 1.0, duration])
	
	# start tween
	tween.interpolate_property($ColorRect, @"self_modulate:a",
		initial_value, 1.0, duration, Tween.TRANS_LINEAR)
	tween.start()
	
	set_meta('current_fade', 'out') # fade type

func queue_fade(type: String, options: Dictionary = {}) -> void:
	assert(type in ['in', 'out'], "invalid fade type, must be 'in' or 'out'")
	_queued_fade.push_back(['fade_' + type, options])

func queue_next_scene(scene: String, deferred: bool = false) -> void:
	_queued_scene.push_back([scene, deferred])

func _on_all_tweens_completed() -> void:
	var cf: String = get_meta('current_fade')
	emit_signal('fade_finished', cf)
	if cf == 'out':
		_load_queued_scene()

func _go_to_next_scene(scene: String):
	var t := get_tree()
	t.connect('idle_frame', self, '_start_queued_fade', [], CONNECT_ONESHOT)
	t.change_scene(scene)

func _load_queued_scene() -> void:
	var ar = _queued_scene.pop_front()
	if ar:
		var scene: String = ar[0]
		var deferred: bool = ar[1]
		if deferred:
			call_deferred('_go_to_next_scene', scene)
		else:
			_go_to_next_scene(scene)

func _start_queued_fade() -> void:
	var ar = _queued_fade.pop_front()
	if ar:
		var m: String = ar[0]
		var o: Dictionary = ar[1]
		call(m, o)
