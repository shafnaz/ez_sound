@tool
extends Button
#extends TreeItem
@onready var label = %label
@onready var margin = %margin
@onready var spectrum = %spectrum

func _ready():
	self.pressed.connect(_on_pressed)

func _toggled(toggled_on):
	_on_pressed()

func _on_pressed():
	if self.button_pressed == true:
		self.custom_minimum_size.y = 80
		spectrum.modulate = Color.WHITE
		spectrum.modulate.a = 1
		spectrum.show_behind_parent = false
		margin.show()
	else:
		margin.hide()
		spectrum.show_behind_parent = true
		spectrum.modulate = Color.GOLD
		spectrum.modulate.a = 0.2
		self.custom_minimum_size.y = 30


#func _get_drag_data(position):
	#var inst = Label.new()
	#RenderingServer.canvas_item_set_z_index(inst.get_canvas_item(), 100)
	#inst.set_script(load("res://addons/ez_sound/drag_preview.gd"))
	#inst.text = file_name
	#self.get_viewport().add_child(inst)
	#var data =	{
		#"file_path" : file_path,
		#"file_name" : file_name,
				#} 
	#return data
#
#
#func _can_drop_data(position, data):
	#return true
#
#
#func _drop_data(position, data):
	#print("###################")
	#print("dropped.")
	#print(position)
	#print(data)
	#print(dock)
	#print("###################")
	
