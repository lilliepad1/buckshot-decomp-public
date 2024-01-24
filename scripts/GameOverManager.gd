class_name GameOverManager extends Node

func PlayerWon():
	get_tree().change_scene_to_file("res://scenes/win.tscn")	
