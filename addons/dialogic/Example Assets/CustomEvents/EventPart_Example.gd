tool
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"
 # has an event_data variable that stores the current data!!!

 ## node references
 # e.g. 
onready var input_field = $InputField

onready var enabled_view = $HBox/Values
onready var definition_picker = $HBox/Values/DefinitionPicker
onready var condition_type_picker = $HBox/Values/ConditionTypePicker
onready var value_input = $HBox/Values/Value

onready var optional_view = $HBox/HasCondition
onready var use_condition_check = $HBox/HasCondition/UseCondition

# has an event_data variable that stores the current data!!!
export (bool) var allow_portrait_dont_change := true
export (bool) var allow_portrait_defintion := true

## node references
onready var character_picker = $HBox/CharacterPicker
onready var portrait_picker = $HBox/PortraitPicker
onready var definition_picker2 = $HBox/DefinitionPicker

 # used to connect the signals
func _ready():
	# e.g. 
	input_field.connect("text_changed", self, "_on_InputField_text_changed")
	
	# Condition picker
	definition_picker.connect("data_changed", self, '_on_DefinitionPicker_data_changed')
	condition_type_picker.connect("data_changed", self, '_on_ConditionTypePicker_data_changed')
	value_input.connect("text_changed", self, "_on_Value_text_changed")
	use_condition_check.connect("toggled", self, "_on_UseCondition_toggled")
	
	# Character/portrait picker
	if DialogicUtil.get_character_list().size() == 0:
		character_picker.hide()
		portrait_picker.hide()
		definition_picker2.hide()
	character_picker.connect("data_changed", self, "_on_CharacterPicker_data_changed")
	portrait_picker.connect("data_changed", self, "_on_PortraitPicker_data_changed")
	portrait_picker.allow_dont_change = allow_portrait_dont_change
	portrait_picker.allow_definition = allow_portrait_defintion
	definition_picker2.connect("data_changed", self, "_on_DefinitionPicker2_data_changed")

 # called by the event block
func load_data(data:Dictionary):
	# First set the event_data
	.load_data(data)
	
	# Condition picker
	definition_picker.load_data(data)
	condition_type_picker.load_data(data)
	value_input.text = data['value']
	optional_view.hide()
	
	# Character/portrait picker
	portrait_picker.load_data(data)
	character_picker.load_data(data)
	portrait_picker.visible = get_character_data() and len(get_character_data()['portraits']) > 1
	
	var has_port_defn = data['portrait'] == '[Definition]'
	if has_port_defn and data.has('port_defn'):
		definition_picker2.load_data({ 'definition': data['port_defn'] })
	definition_picker2.visible = has_port_defn

func get_character_data():
	for ch in DialogicUtil.get_character_list():
		if ch['file'] == event_data['character']:
			return ch

 # has to return the wanted preview, only useful for body parts
func get_preview():
	return ''

 ## EXAMPLE CHANGE IN ONE OF THE NODES
func _on_InputField_text_changed(text):
	event_data['my_text_key'] = text
	
	# informs the parent about the changes!
	data_changed()

# Condition picker

func _on_UseCondition_toggled(checkbox_value):
	enabled_view.visible = checkbox_value
	if checkbox_value == false:
		event_data['definition'] = ''
		event_data['condition'] = ''
		event_data['value'] = ''
	
	data_changed()

func _on_DefinitionPicker_data_changed(data):
	event_data = data
	
	data_changed()

func _on_ConditionTypePicker_data_changed(data):
	event_data = data
	check_data()
	data_changed()
	
	# Focusing the value input
	value_input.call_deferred('grab_focus')

func _on_Value_text_changed(text):
	event_data['value'] = text
	check_data()
	
	data_changed()

func check_data():
	if event_data['condition'] != '==' and event_data['condition'] != '!=':
		if not event_data['value'].is_valid_float():
			emit_signal("set_warning", DTS.translate("The selected operator requires a number!"))
			return
	
	emit_signal("remove_warning")

# Character/portrait picker

func _on_CharacterPicker_data_changed(data):
	event_data = data
	
	# update the portrait picker data
	portrait_picker.load_data(data)
	portrait_picker.visible = get_character_data() and len(get_character_data()['portraits']) > 1
	
	# informs the parent about the changes!
	data_changed()


func _on_PortraitPicker_data_changed(data):
	event_data = data
	
	# update the portrait picker data
	character_picker.load_data(data)
	definition_picker.visible = event_data['portrait'] == '[Definition]'
	
	# informs the parent about the changes!
	data_changed()


func _on_DefinitionPicker2_data_changed(data):
	event_data['port_defn'] = data['definition']

	# informs the parent about the changes!
	data_changed()
