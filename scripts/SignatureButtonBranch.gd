class_name SignButton extends Node

var parent : Node3D
var intbranch : InteractionBranch
@export var y_up : float
@export var y_down :  float
@export var dur : float
var elapsed = 0
var moving = false
var cur
var next

func _ready():
	parent = get_parent()
	intbranch = parent.get_child(1)

func _process(delta):
	Lerp()

func Press():
	intbranch.interactionAllowed = false
	cur = y_up
	next = y_down
	elapsed = 0
	moving = true
	await get_tree().create_timer(.06, false).timeout
	moving = false
	cur = y_down
	next = y_up
	elapsed = 0
	moving = true
	await get_tree().create_timer(.06, false).timeout
	moving = false
	intbranch.interactionAllowed = true

func Lerp():
	if (moving):
		elapsed += get_process_delta_time()
		var c = elapsed / dur
		var temp_pos = lerpf(cur, next, c)
		parent.transform.origin = Vector3(parent.transform.origin.x, temp_pos, parent.transform.origin.z)
