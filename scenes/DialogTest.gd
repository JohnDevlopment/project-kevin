extends Node2D

onready var sprint_meter

func _enter_tree() -> void:
	sprint_meter = $CanvasLayer/PlayerHUD/Counters/HBoxContainer/SprintMeter

func _ready() -> void:
	TransitionRect.fade_in({duration = 1.0})
	$CanvasLayer/DebugOverlay.add_stat('Kevin Detected', $NPCBase, '_kevin_detected', false)

func _on_Kevin_sprint_meter_update_parameters(min_value, max_value) -> void:
	sprint_meter.min_value = min_value
	sprint_meter.max_value = max_value

func _on_Kevin_sprint_meter_updated(value) -> void:
	sprint_meter.value = value
