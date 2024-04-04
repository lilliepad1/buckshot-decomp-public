class_name ResetManager extends Node

@export var save : SaveFileManager
var fs = false

func _unhandled_input(event):
	if (event.is_action_pressed("reset") && !fs):
		save.ClearSave()
		get_tree().change_scene_to_file("res://scenes/death.tscn")
		fs = true
