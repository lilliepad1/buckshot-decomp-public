class_name ShellExamine extends Node

@export var shellSpawner : ShellSpawner
@export var shellParent : Node3D
@export var mesh : MeshInstance3D
@export var mat : StandardMaterial3D
@export var mat_blank : StandardMaterial3D
@export var mat_live : StandardMaterial3D

func _ready():
	shellParent.visible = false

func SetupShell():
	var color_blue = Color(0, 0, 1)
	var color_red = Color(1, 0, 0)
	var shellState = shellSpawner.sequenceArray[0]
	if (shellState == "live"):
		mesh.set_surface_override_material(1, mat_live)
	else:
		mesh.set_surface_override_material(1, mat_blank)
	shellParent.visible = true

func RevertShell():
	shellParent.visible = false
