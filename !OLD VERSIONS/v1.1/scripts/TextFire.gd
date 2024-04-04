class_name TextFire extends Node

var ui : Control
var speaker : AudioStreamPlayer2D
@export var max_x : float
@export var max_y : float
@export var duration : float

var orig_x : float
var orig_y : float
var moving = false
var elapsed = 0
var changed = false


func _ready():
	speaker = get_parent().get_child(1)
	ui = get_parent()

func Fire():
	if (!changed): speaker.pitch_scale = randf_range(.95, 1)
	speaker.play()
	orig_x = ui.scale.x
	orig_y = ui.scale.y
	elapsed = 0
	moving = true
	ui.visible = true

func _process(delta):
	Lerp()

func Lerp():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / duration, 0.0, 1.0)
		c = ease(c, 0.4)
		var temp_x = lerpf(max_x, orig_x, c)
		var temp_y = lerpf(max_y, orig_y, c)
		ui.scale.x = temp_x
		ui.scale.y = temp_y
