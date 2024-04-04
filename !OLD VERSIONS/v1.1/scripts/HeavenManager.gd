class_name Heaven extends Node

@export var cursor : CursorManager
@export var viewblocker : Control
@export var speaker_music : AudioStreamPlayer2D
@export var animator : AnimationPlayer
@export var intbranch_heavendoor : InteractionBranch
@export var interactionManager : InteractionManager
@export var buttonArray : Array[ButtonClass]
@export var speaker_button : AudioStreamPlayer2D

func _ready():
	Signals()
	BeginLoop()

func Signals():
	buttonArray[0].is_pressed.connect(Button_Retry)
	buttonArray[1].is_pressed.connect(Button_Exit)
	pass

func Button_Retry():
	Button_Main("retry")

func Button_Exit():
	Button_Main("exit")

func Button_Main(tag : String):
	speaker_music.stop()
	speaker_button.play()
	cursor.SetCursor(false, false)
	animator.play("fade out")
	for cl in buttonArray:
		cl.isActive = false
	await get_tree().create_timer(3.12, false).timeout
	match tag:
		"retry":
			get_tree().change_scene_to_file("res://scenes/death.tscn")
		"exit":
			get_tree().quit()

func BeginLoop():
	await get_tree().create_timer(1, false).timeout
	speaker_music.play()
	viewblocker.visible = false
	animator.play("camera pan down")
	animator.queue("camera idle")
	await get_tree().create_timer(11.1, false).timeout
	cursor.SetCursor(true, true)
	intbranch_heavendoor.interactionAllowed = true

func Fly():
	intbranch_heavendoor.interactionAllowed = false
	cursor.SetCursor(false, false)
	animator.play("move")
	await get_tree().create_timer(15.6, false).timeout
	cursor.SetCursor(true, true)
	interactionManager.checking = false
	for cl in buttonArray:
		cl.isActive = true
	pass
