class_name ShellDropManager extends Node

@export var speaker : AudioStreamPlayer2D
@export var soundArray : Array[AudioStream]

func PlayShellDropSound():
	var randindex = randi_range(0, soundArray.size() - 1)
	speaker.stream = soundArray[randindex]
	speaker.play()
