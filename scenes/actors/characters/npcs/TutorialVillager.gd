tool
extends "res://scenes/actors/characters/npcs/NPCBase.gd"

export var timeline_prefix := ""

func _on_dialogic_signal(param: String) -> void:
	timeline = param
