class_name Blockout extends Node

@export var objArray_club : Array[Node3D]

func HideClub():
	for i in range(objArray_club.size()):
		objArray_club[i].visible = false
