extends Node2D

onready var sprint_meter

func _enter_tree() -> void:
	sprint_meter = $CanvasLayer/PlayerHUD/Counters/HBoxContainer/SprintMeter

func _ready() -> void:
	TransitionRect.fade_in({duration = 1.0})

func _unhandled_input(event: InputEvent):
	if event is InputEventKey:
		if event.is_action_pressed("debug"):
			var debug_console = $CanvasLayer/DebugConsole
			if not debug_console.active:
				debug_console.activate()
				get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_start"):
			var ps: Control = Game.Scenes.pause_screen.instance()
			$CanvasLayer.add_child(ps)
			get_tree().set_input_as_handled()

func _on_Kevin_sprint_meter_update_parameters(min_value, max_value) -> void:
	sprint_meter.min_value = min_value
	sprint_meter.max_value = max_value

func _on_Kevin_sprint_meter_updated(value) -> void:
	sprint_meter.value = value
