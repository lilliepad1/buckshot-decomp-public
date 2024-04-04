class_name DefibBlade extends Node

@export var anim : AnimationPlayer
@export var speaker : AudioStreamPlayer2D
@export var sound_open : AudioStream
@export var sound_close : AudioStream
@export var wire_normal : Node3D
@export var wire_broken : Node3D

func Blade(state : String, playSound : bool):
	anim.play(state)
	if (state == "open"): speaker.stream = sound_open
	else: 
		speaker.stream = sound_close
		wire_normal.visible = false
		wire_broken.visible = true
	if (playSound): speaker.play()
