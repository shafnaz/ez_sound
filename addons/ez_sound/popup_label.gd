@tool
extends Label

@onready var timer = $Timer

func popup_label(pos, info):
	self.text = info
	self.global_position = pos
	timer.start(1)
	self.modulate.a = 0
	self.create_tween().tween_property(self, "modulate:a", 1, 0.1)
	self.create_tween().tween_property(self, "modulate:a", 0, 0.1).set_delay(0.8)
	self.show()
	timer.start(1)


func _ready():
	self.hide()
	timer.timeout.connect(self.queue_free) 
