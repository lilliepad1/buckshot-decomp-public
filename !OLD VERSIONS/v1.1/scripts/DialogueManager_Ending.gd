class_name DialogueEnding extends Node

@export var speaker_click : AudioStreamPlayer2D
@export var soundArray_clicks : Array[AudioStream]
@export var dialogueUI : Label
@export var dialogueSpeed : float
@export var incrementDelay : float

var elapsed = 0
var moving = false
var looping = false

func _ready():
	speaker_click.stream = soundArray_clicks[0]

func ShowText_Forever(activeText : String):
	looping = false
	dialogueUI.visible_characters = 0
	dialogueUI.text = activeText
	dialogueUI.visible = true
	looping = true
	TickText()

func HideText():
	looping = false
	dialogueUI.visible = false
	pass

func TickText():
	while(looping):
		dialogueUI.visible_characters += 1
		speaker_click.pitch_scale = randf_range(.8, 1)
		speaker_click.play()
		if (dialogueUI.visible_ratio >= 1):
			looping = false
		await get_tree().create_timer(incrementDelay, false).timeout
		pass
	pass
