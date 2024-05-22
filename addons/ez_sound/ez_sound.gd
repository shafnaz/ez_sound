extends Node


@onready var tracks_sfx = $tracks_sfx
@onready var track_music = $track_music
const USER_SETTING_PATH = "ez_sound/ez_sound_path"
const USER_SETTING_RANDOMIZE_PITCH = "ez_sound/ez_sound_randomize_pitch"
const USER_SETTING_RAND_PITCH_MIN = "ez_sound/ez_sound_rand_pitch_min"
const USER_SETTING_RAND_PITCH_MAX = "ez_sound/ez_sound_rand_pitch_max"

enum sound_type {
	SFX,
	MUSIC,
}


func _delete_all_music_tracks():
	for each in track_music.get_children():
		var nd = track_music.get_child(0)


func get_dir():
	return ProjectSettings.get_setting(USER_SETTING_PATH, null)


func get_randomize_pitch():
	return ProjectSettings.get_setting(USER_SETTING_RANDOMIZE_PITCH, false)


func get_pitch_rand_min():
	return ProjectSettings.get_setting(USER_SETTING_RAND_PITCH_MIN, 0.95)


func get_pitch_rand_max():
	return  ProjectSettings.get_setting(USER_SETTING_RAND_PITCH_MAX, 1.05)


func play_music(filename, looped = true, volume_db : float = 0, pitch_scale : float = 1.0):
	await get_tree().process_frame # in case this method is called right after fade_out_current_music, so that this track does not get deleted too.
	var new_audiostream = AudioStreamPlayer.new()
	new_audiostream.bus = "ez_sound_bus"
	new_audiostream.set_pitch_scale(clamp(pitch_scale, 0.5, 2))
	new_audiostream.volume_db = volume_db
	new_audiostream.finished.connect(_on_music_finished.bind(new_audiostream, filename, looped))
	track_music.add_child(new_audiostream)
	new_audiostream.stream = load(get_dir() + filename)
	new_audiostream.play()
	return new_audiostream


func _on_music_finished(audiostream: AudioStreamPlayer, filename, looped):
	if looped:
		audiostream.play(0)
	return


func fade_out_current_music(fade_time = 2):
	var tracks = track_music.get_children()
	for each in tracks:
		get_tree().create_tween().tween_property(each, "volume_db", -50, fade_time).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		await get_tree().create_timer(fade_time).timeout
		each.queue_free()


func get_current_music() -> AudioStreamPlayer:
	if track_music.get_child_count() > 0:
		return track_music.get_child(0)
	return null


func play_sfx(filename, start_at = 0,  volume_db : float = 0, pitch_scale : float = 1.0):
	var new_audiostream = AudioStreamPlayer.new()
	new_audiostream.bus = "ez_sound_bus"
	tracks_sfx.add_child(new_audiostream)
	new_audiostream.volume_db = volume_db
	new_audiostream.set_pitch_scale(pitch_scale)
	if get_randomize_pitch() == true:
		new_audiostream.set_pitch_scale(randf_range(get_pitch_rand_min(), get_pitch_rand_max()))
	new_audiostream.finished.connect(new_audiostream.queue_free)
	new_audiostream.stream = load(get_dir() + filename)
	new_audiostream.play(start_at)
	return new_audiostream

