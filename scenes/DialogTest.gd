extends Node2D

onready var sprint_meter

func _enter_tree() -> void:
	sprint_meter = $CanvasLayer/PlayerHUD/Counters/HBoxContainer/SprintMeter

func _ready() -> void:
	TransitionRect.fade_in({duration = 1.0})
	yield( get_tree().create_timer(1), 'timeout' )
	$Villager1.start_dialog()
	#var dlg = Dialogic.start('villager1_start')
	#add_child(dlg)

func _on_Kevin_sprint_meter_update_parameters(min_value, max_value) -> void:
	sprint_meter.min_value = min_value
	sprint_meter.max_value = max_value

func _on_Kevin_sprint_meter_updated(value) -> void:
	sprint_meter.value = value
