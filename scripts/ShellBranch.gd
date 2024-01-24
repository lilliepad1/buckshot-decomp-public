class_name ShellClass extends Node

@export var isLive : bool
@export var mat_live : StandardMaterial3D
@export var mat_blank : StandardMaterial3D
@export var mesh : MeshInstance3D

func _ready():
	pass

func _process(delta):
	pass

func ApplyStatus():
	if (isLive):
		mesh.set_surface_override_material(1, mat_live)
	else:
		mesh.set_surface_override_material(1, mat_blank)
	pass
