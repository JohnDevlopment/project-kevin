extends Node2D

onready var debug_console = $CanvasLayer/DebugConsole
var sprint_meter # = $CanvasLayer/PlayerHUD/Counters/HBoxContainer/SprintMeter

func _unhandled_input(event: InputEvent):
	if event is InputEventKey:
		if event.is_action_pressed("debug"):
			if not debug_console.active:
				debug_console.activate()
				get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_start"):
			var ps: Control = Game.Scenes.pause_screen.instance()
			$CanvasLayer.add_child(ps)
			get_tree().set_input_as_handled()

func _enter_tree() -> void:
	sprint_meter = $CanvasLayer/PlayerHUD/Counters/HBoxContainer/SprintMeter

func _start_fade_in() -> void:
	yield(get_tree().create_timer(0.5), 'timeout')
	Game.set_paused(true)
	TransitionRect.fade_in({duration = 3.0})
	yield(TransitionRect, 'fade_finished')
	Game.set_paused(false)

func _ready():
	var packed_overlay = load("res://scenes/DebugOverlay.tscn")
	var overlay = packed_overlay.instance()
	add_child(overlay)
	move_child(overlay, $CanvasLayer.get_index())
	
	overlay.add_stat("Input disabled", $Kevin, "disable_input", false)
	overlay.add_stat("Direction", $Kevin, "direction", false)
	
	#overlay.add_stat("Dark Beast->direction", $DarkBeast, "direction", false)
	
	debug_console.command_handler.initial_position = $Kevin.global_position
	
	call_deferred('_start_fade_in')

func _on_Kevin_sprint_meter_update_parameters(min_value: float, max_value: float):
	sprint_meter.min_value = min_value
	sprint_meter.max_value = max_value

func _on_Kevin_sprint_meter_updated(value: float):
	sprint_meter.value = value
