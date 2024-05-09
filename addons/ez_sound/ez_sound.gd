extends Node

var dir = ""

@onready var tracks_sfx = $tracks_sfx
@onready var track_music = $track_music

const USER_SETTING_PATH = "ez_sound/ez_sound_path"

enum sound_type {
	SFX,
	MUSIC,
}


func _delete_all_music_tracks():
	for each in track_music.get_children():
		var nd = track_music.get_child(0)


func _ready():
	#set dir
	dir = ProjectSettings.get_setting(USER_SETTING_PATH, null)


func play_music(filename, looped = true, volume_db : float = 0, pitch_scale : float = 1.0):
	await get_tree().process_frame # in case this method is called right after fade_out_current_music, so that this track does not get deleted too.
	var new_audiostream = AudioStreamPlayer.new()
	new_audiostream.set_pitch_scale(clamp(pitch_scale, 0.5, 2))
	new_audiostream.volume_db = volume_db
	new_audiostream.finished.connect(_on_music_finished.bind(new_audiostream, filename, looped))
	track_music.add_child(new_audiostream)
	new_audiostream.stream = load(dir + filename)
	new_audiostream.play()
	return new_audiostream


func _on_music_finished(audiostream: AudioStreamPlayer, filename, looped):
	if looped:
		audiostream.play(0)
	return


func fade_out_current_music(fade_time = 2):
	var tracks = track_music.get_children()
	for each in tracks:
		get_tree().create_tween().tween_property(each, each.volume, 0, fade_time).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(fade_time).timeout
		each.queue_free()


func get_current_music() -> AudioStreamPlayer:
	if track_music.get_child_count() > 0:
		return track_music.get_child(0)
	return null


func play_sfx(filename, start_at = 0,  volume_db : float = 0, pitch_scale : float = 1.0):
	await get_tree().process_frame # in case this method is called right after fade_out_current_music, so that this track does not get deleted too.
	var new_audiostream = AudioStreamPlayer.new()
	tracks_sfx.add_child(new_audiostream)
	new_audiostream.set_pitch_scale(clamp(pitch_scale, 0.5, 2))
	new_audiostream.volume_db = volume_db
	new_audiostream.finished.connect(new_audiostream.queue_free)
	new_audiostream.stream = load(dir + filename)
	new_audiostream.play(start_at)
	return new_audiostream

