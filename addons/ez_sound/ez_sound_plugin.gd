@tool
extends EditorPlugin

var dock


func _enter_tree():
	self.add_autoload_singleton("ez_sound", "res://addons/ez_sound/ez_sound.tscn")
	dock = load("res://addons/ez_sound/ez_sound_gui.tscn").instantiate()
	self.add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UL, dock)




func _exit_tree():
	self.remove_autoload_singleton("ez_sound")
	self.remove_control_from_docks(dock)
	dock.free()
