extends Control

func _ready():
	for node in get_tree().get_nodes_in_group("get_result"):
		(node as Node).call("_connect", self, "_got_result")

func _got_result(value, op: String, udata1, udata2):
	match op:
		"dot":
			$ResultWindow.dialog_text = "the dot product of %s and %s is %f" % [udata1, udata2, value]
			$ResultWindow.popup_centered()
