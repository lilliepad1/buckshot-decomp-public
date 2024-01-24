class_name ShellLoader extends Node

@export var perm : PermissionManager
@export var camera : CameraManager
@export var roundManager : RoundManager
@export var speaker_loadShell : AudioStreamPlayer2D
@export var speaker_rackShotgun : AudioStreamPlayer2D
@export var animator_shotgun : AnimationPlayer
@export var dialogue : Dialogue
@export var cursor : CursorManager
@export var playerData : PlayerData
@export var shotgunHand_L : Node3D
@export var shotgunHand_R : Node3D
@export var animator_dealerHands : AnimationPlayer
@export var animator_dealerHandRight : AnimationPlayer
@export var dealerAI : DealerIntelligence
@export_multiline var introductionDialogues : Array[String]
@export_multiline var loadingDialogues : Array[String]
var diaindex = 0

func DealerHandsGrabShotgun():
	animator_dealerHands.play("dealer grab shotgun")
	await get_tree().create_timer(.45, false).timeout
	dealerAI.Speaker_HandCrack()
	shotgunHand_L.visible = true
	shotgunHand_R.visible = true

func DealerHandsDropShotgun():
	shotgunHand_L.visible = false
	shotgunHand_R.visible = false
	animator_dealerHands.play("RESET")
	pass

func LoadShells():
	camera.BeginLerp("enemy")
	if (!roundManager.shellLoadingSpedUp): await get_tree().create_timer(.8, false).timeout
	await(DealerHandsGrabShotgun())
	await get_tree().create_timer(.2, false).timeout
	animator_shotgun.play("grab shotgun_pointing enemy")
	await get_tree().create_timer(.45, false).timeout
	if (roundManager.playerData.numberOfDialogueRead < 3):	
		if (diaindex == loadingDialogues.size()):
			diaindex = 0
		dialogue.ShowText_ForDuration(loadingDialogues[diaindex], 3)
		diaindex += 1
		await get_tree().create_timer(3, false).timeout
		roundManager.playerData.numberOfDialogueRead += 1
	var numberOfShells = roundManager.roundArray[roundManager.currentRound].amountBlank + roundManager.roundArray[roundManager.currentRound].amountLive
	for i in range(numberOfShells):
		speaker_loadShell.play()
		animator_dealerHandRight.play("load single shell")
		if(roundManager.shellLoadingSpedUp): await get_tree().create_timer(.17, false).timeout
		else: await get_tree().create_timer(.32, false).timeout
		pass
	animator_dealerHandRight.play("RESET")
	dealerAI.Speaker_HandCrack()
	if (roundManager.shellLoadingSpedUp): await get_tree().create_timer(.17, false).timeout
	else: await get_tree().create_timer(.42, false).timeout
	#INTRODUCTION DIALOGUE
	if (roundManager.roundArray[roundManager.currentRound].hasIntroductoryText):
		dialogue.ShowText_Forever(introductionDialogues[0])
		await get_tree().create_timer(1.9, false).timeout
		dialogue.ShowText_Forever(introductionDialogues[1])
		await get_tree().create_timer(3, false).timeout
		dialogue.ShowText_Forever(introductionDialogues[2])
		await get_tree().create_timer(3, false).timeout
		dialogue.ShowText_Forever(introductionDialogues[3])
		await get_tree().create_timer(3, false).timeout
		dialogue.ShowText_Forever(introductionDialogues[4])
		await get_tree().create_timer(3, false).timeout
		dialogue.ShowText_Forever(introductionDialogues[5])
		await get_tree().create_timer(3.7, false).timeout
		dialogue.ShowText_Forever(introductionDialogues[6])
		await get_tree().create_timer(3.7, false).timeout
		dialogue.ShowText_Forever(introductionDialogues[7])
		await get_tree().create_timer(3.7, false).timeout
		dialogue.ShowText_Forever(introductionDialogues[8])
		await get_tree().create_timer(2.5, false).timeout
		roundManager.playerData.hasReadIntroduction = true
		dialogue.HideText()
	#RACK SHOTGUN, PLACE ON TABLE
	#speaker_rackShotgun.play()
	animator_shotgun.play("enemy rack shotgun start")
	await get_tree().create_timer(.8, false).timeout
	animator_shotgun.play("enemy put down shotgun")
	DealerHandsDropShotgun()
	camera.BeginLerp("home")
	#ALLOW INTERACTION
	await get_tree().create_timer(.6, false).timeout
	perm.SetStackInvalidIndicators()
	cursor.SetCursor(true, true)
	perm.SetIndicators(true)
	perm.SetInteractionPermissions(true)
	pass
