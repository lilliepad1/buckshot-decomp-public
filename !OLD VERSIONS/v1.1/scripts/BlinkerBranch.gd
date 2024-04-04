class_name BlinkerBranch extends Node

@export var mat_1 : StandardMaterial3D
@export var mat_2 : StandardMaterial3D
@export var delay_range1 : float
@export var delay_range2 : float
var parent : MeshInstance3D
var looping = false

func _ready():
	parent = get_parent()
	looping = true
	Loop()
	pass

func Loop():
	while (looping):
		var delay = randf_range(delay_range1, delay_range2)
		parent.set_surface_override_material(0, mat_1)
		await get_tree().create_timer(delay, false).timeout
		parent.set_surface_override_material(0, mat_2)
		await get_tree().create_timer(delay, false).timeout
	pass
