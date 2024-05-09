@tool
extends Label

func _process(delta):
	self.global_position = self.get_global_mouse_position()

func _input(event):
	if event is InputEventScreenDrag:
		print(self.global_position)
		print(self.get_global_mouse_position())
	if event is InputEventMouseButton and event.button_pressed == false:
		self.queue_free()
