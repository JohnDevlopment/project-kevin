extends Node2D

onready var debug_console = $CanvasLayer/DebugConsole

func _unhandled_input(event: InputEvent):
	if event is InputEventKey:
		if event.is_action_pressed("debug"):
			if not debug_console.active:
				debug_console.activate()
				get_tree().set_input_as_handled()

func _ready():
	var packed_overlay = load("res://scenes/DebugOverlay.tscn")
	var overlay = packed_overlay.instance()
	add_child(overlay)
	
	overlay.add_stat("Kevin Velocity", $Kevin, "velocity", false)
	overlay.add_stat("Kevin Speed Cap", $Kevin, "speed_cap", false)
	overlay.add_stat("Kevin is moving", $Kevin, "moving", false)
	overlay.add_stat("Kevin is sprinting", $Kevin, "sprinting", false)
	
	debug_console.command_handler.initial_position = $Kevin.global_position
