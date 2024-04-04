class_name Signature extends Node

@export var roundManager : RoundManager
@export var parent_shotgun : Node3D
@export var parent_waiver : Node3D
@export var parent_separateWaiver : Node3D
@export var parent_signatureMachineMainParent : Node3D
@export var intrbranch_waiver : InteractionBranch
@export var cursor : CursorManager
@export var anim_waiver : AnimationPlayer
@export var intbranches : Array[InteractionBranch]
@export var marker : Label3D
@export var letterArray : Array[Label3D]
@export var ledArray : Array[GeometryInstance3D]
@export var posArray_marker : Array[Vector3]
@export var letterArray_signature_joined : Array[Label3D]
@export var letterArray_signature_separate : Array[Label3D]
@export var speaker_bootup : AudioStreamPlayer2D
@export var speaker_shutdown : AudioStreamPlayer2D
@export var speaker_keypress : AudioStreamPlayer2D
@export var speaker_punch : AudioStreamPlayer2D

var fullstring = ""
var lettercount = 0
var origpos_shotgun
var markerIndex = 0
var blinking = false

func _ready():
	for l in letterArray_signature_joined: l.text = ""
	for l in letterArray_signature_separate: l.text = ""
	parent_signatureMachineMainParent.visible = false
	await get_tree().create_timer(2, false).timeout
	if (roundManager.playerData.hasSignedWaiver == false): SetupWaiver()

func BlinkMarker():
	while(blinking):
		marker.modulate.a = 0
		await get_tree().create_timer(.3, false).timeout
		marker.modulate.a = 1
		await get_tree().create_timer(.3, false).timeout
		pass
	pass

func SetupWaiver():
	origpos_shotgun = parent_shotgun.transform.origin
	parent_shotgun.transform.origin = Vector3(-1.738, -5, -0.041)
	parent_waiver.transform.origin = Vector3(-29.613, -35.341, -6.696)

func AwaitPickup():
	await get_tree().create_timer(.6, false).timeout
	cursor.SetCursor(true, true)
	intrbranch_waiver.interactionAllowed = true

func PickUpWaiver():
	speaker_bootup.play()
	parent_signatureMachineMainParent.visible = true
	intrbranch_waiver.interactionAllowed = false
	cursor.SetCursor(false, false)
	anim_waiver.play("pickup waiver")
	for letter in letterArray: letter.text = ""
	UpdateMarkerPosition()
	UpdateLEDArray()
	blinking = true
	BlinkMarker()
	await get_tree().create_timer(2.77, false).timeout #.9 anim speed
	for intbr in intbranches : intbr.interactionAllowed = true
	cursor.SetCursor(true, true)

func GetInput(letterAlias : String, specialAlias : String):
	speaker_keypress.pitch_scale = randf_range(.95, 1)
	speaker_keypress.play()
	var input
	if (letterAlias != ""): input = letterAlias
	else: input = specialAlias
	if (input != "backspace" && input != "enter"):
		Input_Letter(input)
	else: if (input == "enter"):
		Input_Enter()
	else: if (input == "backspace"):
		Input_Backspace()

func Input_Letter(alias : String):
	if (markerIndex != 6):
		if (letterArray[markerIndex].text == ""): letterArray[markerIndex].text = alias
	if (markerIndex != 6): markerIndex += 1
	UpdateMarkerPosition()
	UpdateLEDArray()
	pass

func Input_Enter():
	var chararray = []
	fullstring = ""
	for letter in letterArray:
		if (letter.text != ""):
			chararray.append(letter.text)
	for l in chararray: fullstring += l
	lettercount = chararray.size()
	if (fullstring == ""): return
	if (fullstring == "dealer"): return
	if (fullstring == "god"): return
	if (fullstring != ""):
		for br in intbranches:
			var el = br.get_parent().get_child(2)
			br.interactionAllowed = false
			el.set_collision_layer_value(1, false)
			el.set_collision_mask_value(1, false)
	cursor.SetCursor(false, false)
	await get_tree().create_timer(.25, false).timeout
	for i in range(lettercount):
		letterArray_signature_joined[i].text = chararray[i].to_upper()
		letterArray_signature_separate[i].text = chararray[i].to_upper()
		ledArray[i].visible = false
		await get_tree().create_timer(.17, false).timeout
		speaker_punch.pitch_scale = randf_range(.95, 1)
		speaker_punch.play()
	await get_tree().create_timer(.17, false).timeout
	parent_shotgun.transform.origin = origpos_shotgun
	anim_waiver.play("put away waiver")
	speaker_bootup.stop()
	speaker_shutdown.play()
	roundManager.playerData.playername = fullstring
	roundManager.playerData.hasSignedWaiver = true
	ReturnToMainBatch()
	await get_tree().create_timer(1.72, false).timeout
	parent_signatureMachineMainParent.visible = false
	parent_separateWaiver.visible = false
	await get_tree().create_timer(.4, false).timeout
	parent_waiver.queue_free()

func ReturnToMainBatch():
	await get_tree().create_timer(1.27, false).timeout
	roundManager.enteringFromWaiver = true
	roundManager.MainBatchSetup(false)

func Input_Backspace():
	if (markerIndex != 6 && markerIndex != 0): letterArray[markerIndex - 1].text = ""
	if (markerIndex == 6): letterArray[markerIndex - 1].text = ""
	if (markerIndex != 0): markerIndex -= 1
	UpdateMarkerPosition()
	UpdateLEDArray()
	pass

func UpdateMarkerPosition():
	if(markerIndex != 6): marker.transform.origin = posArray_marker[markerIndex]
	if (markerIndex == 5 && letterArray[markerIndex].text != ""): marker.visible = false
	else: if (markerIndex == 6): marker.visible = false
	else: marker.visible = true

func UpdateLEDArray():
	for i in range(ledArray.size()):
		if letterArray[i].text != "":
			ledArray[i].transparency = 0
		else:
			ledArray[i].transparency = 1




















