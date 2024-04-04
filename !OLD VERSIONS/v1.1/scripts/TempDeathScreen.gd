class_name TempDeathScreen extends Node

@export var isDeathScreen : bool
@export var savefile : SaveFileManager
@export var viewblocker : ColorRect
@export var speaker : AudioStreamPlayer2D
var allowed = true
var fs = false

func _ready():
	if (isDeathScreen):
		get_tree().change_scene_to_file("res://scenes/main.tscn")

#func _unhandled_input(event):
#	if (event.is_action_pressed("enter") && allowed && !fs):
#		viewblocker.color = Color(0, 0, 0, 1)
#		speaker.pitch_scale = .8
#		await get_tree().create_timer(.5, false).timeout
#		if (!isDeathScreen):
#			savefile.ClearSave()
#		get_tree().change_scene_to_file("res://scenes/main.tscn")
#		allowed = false
