tool
extends "res://scenes/actors/characters/npcs/NPCBase.gd"

func _on_dialogic_signal(param: String) -> void:
	match param:
		'tm_mess':
			timeline = 'beta1/villager1_mess'
		'tm_do':
			timeline = 'beta1/villager1_dotut'
