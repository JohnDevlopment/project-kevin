extends Node

var definitions := {}

func handle_event(event_data: Dictionary, dialog_node: Node):
	var def_value = null
	
	# HACK: I'm not sure I should do this, but oh well.
	definitions = Engine.get_main_loop().get_meta('definitions')
	
	for d in definitions['variables']:
		if d['id'] == event_data['definition']:
			def_value = d['value']
	
	var condition_met: bool = def_value != null and _compare_definitions(def_value, event_data['value'], event_data['condition'])
	
	if condition_met:
		dialog_node.emit_signal("event_start", "text", event_data)
		dialog_node.fade_in_dialog()
		dialog_node.finished = false
		if event_data.has('character'):
			var character_data = dialog_node.get_character(event_data['character'])
			dialog_node.update_name(character_data)
			dialog_node.grab_portrait_focus(character_data, event_data)
		#voice 
		dialog_node.handle_voice(event_data)
		dialog_node.update_text(event_data['text'])
	else:
		# once you want to continue with the next event
		dialog_node._load_next_event()
		dialog_node.waiting = false
		dialog_node.finished = true

# returns the result of the given dialogic comparison
func _compare_definitions(def_value: String, event_value: String, condition: String):
	var condition_met = false;
	if def_value != null and event_value != null:
		# check if event_value equals a definition name and use that instead
		for d in definitions['variables']:
			if (d['name'] != '' and d['name'] == event_value):
				event_value = d['value']
				break;
		var converted_def_value = def_value
		var converted_event_value = event_value
		if def_value.is_valid_float() and event_value.is_valid_float():
			converted_def_value = float(def_value)
			converted_event_value = float(event_value)
		if condition == '':
			condition = '==' # The default condition is Equal to
		match condition:
			"==":
				condition_met = converted_def_value == converted_event_value
			"!=":
				condition_met = converted_def_value != converted_event_value
			">":
				condition_met = converted_def_value > converted_event_value
			">=":
				condition_met = converted_def_value >= converted_event_value
			"<":
				condition_met = converted_def_value < converted_event_value
			"<=":
				condition_met = converted_def_value <= converted_event_value
	#print('comparing definition: ', def_value, ',', event_value, ',', condition, ' - ', condition_met)
	return condition_met
