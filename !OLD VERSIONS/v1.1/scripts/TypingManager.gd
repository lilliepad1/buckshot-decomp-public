class_name TypingManager extends Node

@export var speaker_click : AudioStreamPlayer2D
@export var dialogueUI : Label3D
@export var dialogueSpeed : float
@export var incrementDelay : float

var elapsed = 0
var moving = false
var looping = false

func ShowText_ForDuration(activeText : String, showDuration : float):
	looping = false
	dialogueUI.visible_characters = 0
	dialogueUI.text = activeText
	dialogueUI.visible = true
	looping = true
	TickText()
	await get_tree().create_timer(showDuration, false).timeout
	looping = false
	dialogueUI.visible = false

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
		speaker_click.play()
		if (dialogueUI.visible_ratio >= 1):
			looping = false
		await get_tree().create_timer(incrementDelay, false).timeout
		pass
	pass
