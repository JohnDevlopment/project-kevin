tool
extends WindowDialog

onready var InputFile: LineEdit = $MarginContainer/List/FileLine/InputFile
onready var OutputFile: LineEdit = $MarginContainer/List/FileLine2/OutputFile
onready var GetResourceFile: FileDialog = $GetResourceFile
onready var ErrorDialog: AcceptDialog = $ErrorDialog
onready var image_height = $MarginContainer/List/Options/ImageHeight

#func _ready() -> void:
#	if not Engine.editor_hint:
#		call_deferred('show_dialog')
#		TransitionRect.call_deferred('set_alpha', 0)

func show_dialog() -> void:
	popup_centered(Vector2(460, 400))

func _create_image_from_gradient(gradient: Image, height: int):
	var err := OK
	
	# Decompress data if applicable.
	if gradient.is_compressed():
		err = gradient.decompress()
		if err:
			ErrorDialog.show_dialog("Unable to decompress image data.")
			return err
	
	# Check for invalid width
	var gradw : int = gradient.get_width()
	if gradw == 0:
		ErrorDialog.show_dialog("Gradient width is zero.")
		return ERR_INVALID_DATA
	
	var result := Image.new()
	result.create(gradw, height, false, Image.FORMAT_RGB8)
	
	gradient.lock()
	result.lock()
	
	# Copy the gradient pixels to each row in the resultant file
	for y in height:
		for x in gradw:
			var pixel : Color = gradient.get_pixel(x, 0)
			result.set_pixel(x, y, pixel)
	
	gradient.unlock()
	result.unlock()
	
	return result

# Signals

func _on_BrowseFile_pressed() -> void:
	GetResourceFile.popup_centered(Vector2(400, 400))

func _on_GetResourceFile_file_selected(path: String) -> void:
	InputFile.text = path
	OutputFile.text = path.get_basename() + ".png"

func _on_Convert_pressed() -> void:
	var ifile : String = InputFile.text
	var ofile : String = OutputFile.text
	
	if ifile.empty() or ofile.empty():
		printerr('Empty file path.')
		return
	
	# Load gradient texture
	var grad = load(ifile)
	if not grad is GradientTexture:
		printerr("Invalid file '%s': not a GradientTexture." % ifile)
		return
	
	# Get image data for the gradient
	var img = grad.get_data()
	if not img:
		printerr("Failed to get image data from gradient.")
		return
	
	var err := OK
	
	# Create a copy of the gradient with the specified height
	img = _create_image_from_gradient(img, int(image_height.value))
	if img is int: return
	
	# Save image to PNG file
	err = img.save_png(ofile)
	if err:
		ErrorDialog.show_dialog("Could not save gradient to '%s'." % ofile)
		return
	
	queue_free()

func _on_Cancel_pressed() -> void:
	queue_free()

func _on_GradientToImage_popup_hide() -> void:
	queue_free()
