class_name CompartmentManager extends Node

@export var animator_compartment : AnimationPlayer
@export var animator_briefcase : AnimationPlayer
@export var speaker_briefcase : AudioStreamPlayer2D
@export var speaker_main : AudioStreamPlayer2D
@export var soundArray_briefcase : Array[AudioStream]
@export var soundArray_main : Array[AudioStream]
var isHiding_items = true

var toggle = false
var toggle2 = false

func _ready():
	animator_compartment.play("RESET")
	animator_briefcase.play("RESET")

func PlaySound_ShowBriefcase():
	speaker_briefcase.stream = soundArray_briefcase[0]
	speaker_briefcase.play()

func PlaySound_HideBriefcase():
	speaker_briefcase.stream = soundArray_briefcase[1]
	speaker_briefcase.play()

func PlaySound_ClearItems():
	speaker_main.stream = soundArray_main[0]
	speaker_main.play()

func PlaySound_ShowItems():
	speaker_main.stream = soundArray_main[1]
	speaker_main.play()

func PlaySound_HideItems():
	speaker_main.stream = soundArray_main[2]
	speaker_main.play()

func CycleCompartment(alias : String):
	match (alias):
		"show items":
			animator_compartment.play("show items")
			isHiding_items = false
		"hide items":
			animator_compartment.play("hide items")
			isHiding_items = true
		"show briefcase":
			animator_briefcase.play("show briefcase")
		"hide briefcase":
			animator_briefcase.play("hide briefcase")
