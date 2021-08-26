extends Control

func _ready():
	for node in get_tree().get_nodes_in_group("get_result"):
		(node as Node).call("_connect", self, "_got_result")

func _got_result(value, op: String, udata: Array):
	match op:
		"dot":
			$ResultWindow.dialog_text = "the dot product of %s and %s is %f" % [udata[0], udata[1], value]
			$ResultWindow.popup_centered()
		"distance_to":
			$ResultWindow.dialog_text = "distance between %s and %s: %f" % [udata[0], udata[1], value]
			$ResultWindow.popup_centered()
