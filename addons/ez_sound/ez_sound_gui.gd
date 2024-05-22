@tool
extends Control

@onready var sound_list = $"%sound_list"
@onready var sp = $"%sp"
@onready var btn_reload = %btn_reload
@onready var button_pause = %button_pause
@onready var button_copy = %button_copy
@onready var stream_bar = %stream_bar
@onready var scroll = %scroll
@onready var filedialog = %filedialog
@onready var label_dir = %label_dir
@onready var btn_dir = %btn_dir
@onready var label_no_dir = %label_no_dir
@onready var label_no_sounds = %label_no_sounds
@onready var button_pitch_randomize = %button_pitch_randomize
@onready var spin_pitch_min = %spin_pitch_min
@onready var spin_pitch_max = %spin_pitch_max

const DRAGGABLE = preload("res://addons/ez_sound/draggable.tscn")
const POPUP_LABEL = preload("res://addons/ez_sound/popup_label.tscn")
const USER_SETTING_PATH = "ez_sound/ez_sound_path"
const USER_SETTING_RANDOMIZE_PITCH = "ez_sound/ez_sound_randomize_pitch"
const USER_SETTING_RAND_PITCH_MIN = "ez_sound/ez_sound_rand_pitch_min"
const USER_SETTING_RAND_PITCH_MAX = "ez_sound/ez_sound_rand_pitch_max"

var selected_sound_button = null
var selected_sound_filename = ""
var btn_group = ButtonGroup.new()


func show_popup_message(pos, message):
	var inst = POPUP_LABEL.instantiate()
	self.add_child(inst)
	await get_tree().process_frame
	inst.popup_label(pos, message)


func _ready():
	set_process_input(false)
	set_process(false)
	button_pitch_randomize.pressed.connect(_on_pitch_randomize_pressed)
	spin_pitch_max.value_changed.connect(_on_pitch_max_changed)
	spin_pitch_min.value_changed.connect(_on_pitch_min_changed)
	filedialog.hide()
	filedialog.dir_selected.connect(_on_dir_selected)
	btn_reload.pressed.connect(_on_reload_pressed)
	button_copy.pressed.connect(_on_copy_pressed)
	button_pause.pressed.connect(_on_pause_pressed)
	btn_dir.pressed.connect(_on_set_dir_pressed)
	stream_bar.gui_input.connect(_on_stream_bar_gui)
	self.resized.connect(update_stream_bar)
	scroll.scroll_started.connect(update_stream_bar)
	scroll.scroll_ended.connect(update_stream_bar)
	label_dir.text = ProjectSettings.get_setting(USER_SETTING_PATH, "No Sounds Dir Set")
	_on_reload_pressed()
	
	button_pitch_randomize.button_pressed = ProjectSettings.get_setting(USER_SETTING_RANDOMIZE_PITCH, false)
	_on_pitch_randomize_pressed()
	set_process_input(true)
	pass


func _on_pitch_max_changed(v):
	ProjectSettings.set_setting(USER_SETTING_RAND_PITCH_MAX, spin_pitch_max.value)

func _on_pitch_min_changed(v):
	ProjectSettings.set_setting(USER_SETTING_RAND_PITCH_MIN, spin_pitch_min.value)


func _on_pitch_randomize_pressed():
	if button_pitch_randomize.button_pressed == true:
		ProjectSettings.set_setting(USER_SETTING_RANDOMIZE_PITCH, true)
		ProjectSettings.set_setting(USER_SETTING_RAND_PITCH_MIN, spin_pitch_min.value)
		ProjectSettings.set_setting(USER_SETTING_RAND_PITCH_MAX, spin_pitch_max.value)
		spin_pitch_max.show()
		spin_pitch_min.show()
	else:
		spin_pitch_max.hide()
		spin_pitch_min.hide()


func _on_set_dir_pressed():
	filedialog.show()
	return


func _on_dir_selected(v:String):
	if not v.ends_with("/"):
		v = v + "/"
	label_dir.text = v
	ProjectSettings.set_setting(USER_SETTING_PATH, v)
	_on_reload_pressed()


func _on_copy_pressed():
	show_popup_message(get_global_mouse_position() + Vector2(-100, -50), "Code Copied!")
	var filename = selected_sound_filename.split("/")[-1]
	DisplayServer.clipboard_set("ez_sound.play_sfx(\"" + filename + "\")")
	return


func _on_pause_pressed():
	sp.playing = false
	return


func _input(ev):
	update_stream_bar()


func _on_reload_pressed():
	selected_sound_button = null
	selected_sound_filename = ""
	stream_bar.hide()
	button_copy.hide()
	button_pause.hide()
	label_no_sounds.hide()
	label_no_dir.hide()
	for each in sound_list.get_children():
		each.queue_free()
	await get_tree().process_frame
	if DirAccess.dir_exists_absolute(label_dir.text):
		var files = list_files_in_directory(label_dir.text)
		if files.is_empty():
			label_no_sounds.show()
		else:
			for each in files:
				var sname = each.replace("." + each.get_extension(), "")
				create_sound_button(sname, label_dir.text + each, each.get_extension())
			label_no_dir.hide()
			label_no_sounds.hide()
	else:
		label_no_dir.show()



func _on_stream_bar_gui(ev):
	if ev is InputEventMouseButton and ev.pressed == true  and ev.button_mask == 1:
		var touchx = ev.position.x
		stream_bar.value = remap(touchx, 0, stream_bar.size.x, stream_bar.min_value, stream_bar.max_value)
		var audio_length = sp.get_stream().get_length()
		sp.play(remap(stream_bar.value, 0, stream_bar.max_value, 0, audio_length))
		set_process(true)


func _process(_delta):
	if stream_bar.value == stream_bar.max_value:
		set_process(false)
	stream_bar.value = remap(sp.get_playback_position(), 0, sp.get_stream().get_length(), stream_bar.min_value, stream_bar.max_value)


func create_sound_button(display_name, file_path, extension):
	var inst = DRAGGABLE.instantiate()
	sound_list.add_child(inst)
	inst.label.text = display_name
	inst.connect("pressed", Callable(self, "_on_sound_button_pressed").bind(inst, file_path))
	inst.button_group = btn_group
	inst.button_pressed = false
	inst.owner = self
	#set image
	if extension == "mp3":
		inst.spectrum.texture = generate_mp3_image(file_path)
	elif extension == "wav":
		inst.spectrum.texture = generate_wav_image(file_path)



func _on_sound_button_pressed(sound_button, file_path):
	button_copy.show()
	button_pause.show()
	selected_sound_button = sound_button
	selected_sound_filename = file_path
	await get_tree().process_frame
	place_stream_bar()
	set_process(true)
	sp.stream = load(file_path)
	if ".mp3" in file_path:
		sp.stream.loop = false
	sp.play()



func place_stream_bar():
	if selected_sound_button != null:
		update_stream_bar()
		stream_bar.show()
	else:
		stream_bar.hide()


func update_stream_bar():
	if selected_sound_button != null:
		stream_bar.global_position.x = selected_sound_button.get_global_rect().position.x
		stream_bar.size.x = selected_sound_button.size.x
		stream_bar.size.y = selected_sound_button.size.y / 2
		stream_bar.global_position.y = selected_sound_button.global_position.y + selected_sound_button.size.y - stream_bar.size.y

		button_copy.size.y = (selected_sound_button.size.y / 2) - 6
		button_copy.size.x = button_copy.size.y
		button_copy.global_position.y = selected_sound_button.global_position.y + 3
		button_copy.global_position.x = selected_sound_button.global_position.x + selected_sound_button.size.x - button_copy.size.x - 3

		button_pause.size.y = (selected_sound_button.size.y / 2) - 6
		button_pause.size.x = button_copy.size.y
		button_pause.global_position.y = selected_sound_button.global_position.y + 3
		button_pause.global_position.x = button_copy.global_position.x - button_copy.size.x - 10

func list_files_in_directory(path):
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				if file_name.ends_with(".mp3") or file_name.ends_with(".wav"):
					files.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return files



func generate_wav_image(filepath:String):
	var bar_width = 3
	var audio_stream_wav : AudioStreamWAV = load(filepath)
	var data = audio_stream_wav.get_data()

	var img = draw_peak_visualization(data, 200, 50, audio_stream_wav.format, false)
	# Create a texture from the image
	var texture = ImageTexture.new()
	texture = texture.create_from_image(img)  # This replaces the deprecated create_from_image(img, 0)
	return texture


func generate_mp3_image(filepath:String):
	var bar_width = 3
	var audio_stream_wav : AudioStreamMP3 = load(filepath)
	var data = audio_stream_wav.get_data()

	var img = draw_peak_visualization(data, 200, 50, 0, true)
	# Create a texture from the image
	var texture = ImageTexture.new()
	texture = texture.create_from_image(img)  # This replaces the deprecated create_from_image(img, 0)
	return texture



func draw_peak_visualization(data: PackedByteArray, width: int, height: int, format: int, is_mp3: bool = false) -> Image:
	var img = Image.new()
	img = img.create(width, height, false, Image.FORMAT_RGBA8)

	var step = max(data.size() / width, 1)
	# Correctly using inline 'if' for GDScript
	var height_factor = height / (65536.0 if is_mp3 or format == AudioStreamWAV.FORMAT_16_BITS else 256.0)

	for i in range(width):
		var idx = int(i * step)
		if idx + (1 if not is_mp3 else 0) >= data.size():
			break

		var sample = 0
		if is_mp3 or format == AudioStreamWAV.FORMAT_16_BITS:
			# Handling 16-bit data
			if idx + 1 < data.size():
				sample = int(data[idx] + data[idx+1] * 256)
				sample = sample if sample < 32768 else sample - 65536
		else:
			# Handling 8-bit data
			sample = int(data[idx]) - 128

		var amplitude = int(sample * height_factor) + height / 2
		amplitude = clamp(amplitude, 0, height - 1)

		# Draw vertical line from middle to amplitude and mirror it
		for y in range(int(height / 2)):
			if y <= abs(int(height / 2) - amplitude):
				img.set_pixel(i, height / 2 + y, Color(1, 1, 1, 1))  # Draw upward from the middle
				img.set_pixel(i, height / 2 - y, Color(1, 1, 1, 1))  # Draw downward from the middle

	return img
