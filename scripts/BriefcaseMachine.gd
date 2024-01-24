class_name BriefcaseMachine extends Node

@export var ending : EndingManager
@export var cam : CameraManager
@export var cursor : CursorManager
@export var parent_eyes : Node3D
@export var parent_machine : Node3D
@export var speaker_machine : AudioStreamPlayer2D
@export var anim_machine : AnimationPlayer
@export var speaker_latchL : AudioStreamPlayer2D
@export var speaker_latchR : AudioStreamPlayer2D
@export var speaker_lid : AudioStreamPlayer2D
@export var anim_latchL : AnimationPlayer
@export var anim_latchR : AnimationPlayer
@export var anim_lid : AnimationPlayer
@export var intbranch_L : InteractionBranch
@export var intbranch_R : InteractionBranch
@export var intbranch_lid : InteractionBranch

var latchRaisedL = false
var latchRaisedR = false

func MainRoutine():
	speaker_machine.play()
	await get_tree().create_timer(.42, false).timeout
	parent_eyes.visible = true
	await get_tree().create_timer(1.28, false).timeout
	parent_eyes.visible = false
	anim_machine.play("move to table")
	parent_machine.visible = true
	await get_tree().create_timer(5.14, false).timeout
	cam.BeginLerp("cash briefcase")
	await get_tree().create_timer(.8, false).timeout
	cursor.SetCursor(true, true)
	intbranch_L.interactionAllowed = true
	intbranch_R.interactionAllowed = true

func CheckLatches():
	if (latchRaisedL == true && latchRaisedR == true):
		await get_tree().create_timer(.3, false).timeout
		intbranch_lid.interactionAllowed = true

func OpenLatch(alias : String):
	match (alias):
		"L":
			intbranch_L.interactionAllowed = false
			speaker_latchL.play()
			anim_latchL.play("raise")
			latchRaisedL = true
			CheckLatches()
		"R":
			intbranch_R.interactionAllowed = false
			speaker_latchR.play()
			anim_latchR.play("raise")
			latchRaisedR = true
			CheckLatches()

func OpenLid():
	cursor.SetCursor(false, false)
	intbranch_lid.interactionAllowed = false
	anim_lid.play("open")
	speaker_lid.play()
	ending.BeginEnding()
