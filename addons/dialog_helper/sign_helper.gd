tool
extends VBoxContainer

const MAX_PREVIEW_LENGTH := 30

var _data: MessageData setget set_data
var _index := -1

func apply_changes() -> void:
	var wr = weakref(_data)
	if wr.get_ref() != null:
		_data.emit_changed()

func edit(data: MessageData):
	reset()
	set_data(data)
	
	# Adds a preview of each string in the list
	for s in data.get_data():
		var preview := _get_item_preview(s as String)
		$ScrollContainer/Entries.add_item(preview)
	
	if _index < 0 and not _data.is_empty():
		$ScrollContainer/Entries.select(0)
		_on_option_item_selected(0)

func reset() -> void:
	$ScrollContainer/Entries.clear()
	$TextEdit.text = ''
	set_data(null)

func set_data(d: MessageData) -> void:
	_data = d

func _get_item_preview(s: String) -> String:
	s = s.replace("\n", '[nl]')
	if s.length() > MAX_PREVIEW_LENGTH:
		s = s.substr(0, MAX_PREVIEW_LENGTH-1) + "..."
	return s

func _ready() -> void:
	if not Engine.editor_hint:
		var m := MessageData.new(["hello", "halo", "gutentag"])
		edit(m)
	if not $EntryOptions.get_popup().is_connected("id_pressed", self, "_on_option_pressed"):
		$EntryOptions.get_popup().connect("id_pressed", self, "_on_option_pressed")

func _on_option_item_selected(index: int) -> void:
	_index = index
	if index < 0:
		$TextEdit.text = ''
	else:
		$TextEdit.text = _data.get_data()[_index]

func _on_option_pressed(id: int):
	match id:
		0:
			# Add item
			var s := _data.get_data()
			s.append("...")
#			_save_text_data(s)
			_data.set_data(s)
			$ScrollContainer/Entries.add_item(s[-1])
			
			var i := s.size() - 1
			$ScrollContainer/Entries.select(i)
			_on_option_item_selected(i)
		1:
			# Save existing item
			if _index >= 0:
				var s := _data.get_data()
				s[_index] = $TextEdit.text
#				_save_text_data(s)
				_data.set_data(s)
				$ScrollContainer/Entries.set_item_text(_index, _get_item_preview(s[_index]))
		2:
			if _index >= 0:
				var s := _data.get_data()
				s.remove(_index)
#				_save_text_data(s)
				_data.set_data(s)
				$ScrollContainer/Entries.remove_item(_index)
				_on_option_item_selected(-1)
