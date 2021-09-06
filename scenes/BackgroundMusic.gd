extends AudioStreamPlayer

export var songs: Dictionary

const MUSIC_PATH := "res://assets/audio/music"

onready var tween = $Tween

func _enter_tree() -> void:
	stream = null

func fade_out(duration: float):
	if not is_playing() or tween.is_active(): return
	if duration <= 0.0:
		push_error("invalid duration %f, needs to be greater than 0" % duration)
		return
	tween.interpolate_property(self, @"volume_db", null, -80.0, duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

func play_music(song: String, position: float = 0.0) -> void:
	var audio_stream = songs.get(song)
	
	if not(song in songs):
		push_error("No song named \"%s\" exists in the list" % song)
		return
	var path := str(MUSIC_PATH, '/', audio_stream as String)
	audio_stream = load(path)
	if audio_stream == null: return
	stream = audio_stream as AudioStream
	play(position)

func _on_tween_completed(object: Object, key: NodePath) -> void:
	if object == self:
		if key == @"volume_db":
			stop()
