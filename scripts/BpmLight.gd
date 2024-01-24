class_name BpmLight extends Node

@export var animator : AnimationPlayer
var delay
var l
var looping = false

func _ready():
	l = get_parent()
	
func BeginMainLoop():
	looping = true
	BeginLoop()
	
func Hit():
	animator.play("hit")
	pass
	
func BeginLoop():
	while (looping):
		Hit()
		await get_tree().create_timer(delay, false).timeout
		Hit()
		await get_tree().create_timer(delay, false).timeout
		pass
	pass
