class_name TextShaker extends Node

@export var delay : float
@export var offset1 : float
@export var offset2 : float
@export var text : Control
var looping = false
var origpos

func _ready():
	origpos = text.position
	looping = true
	Shake()

func Shake():
	while(looping):
		var randx = randf_range(offset1, offset2)
		var randy = randf_range(offset1, offset2)
		text.position = Vector2(randx, randy)
		await get_tree().create_timer(delay, false).timeout
		text.position = origpos
		await get_tree().create_timer(delay, false).timeout
		pass
	pass
