class_name HandcuffManager extends Node

@export var dealerAI : DealerIntelligence
@export var roundManager : RoundManager
@export var camera : CameraManager
@export var animator_handcuffsPlayer : AnimationPlayer
@export var handcuffs_player : Node3D

var previousSocket

func AttachHandCuffs():
	animator_handcuffsPlayer.play("RESET")
	await get_tree().create_timer(.1, false).timeout
	handcuffs_player.visible = true

func CheckPlayerHandCuffs(lerpingToPrevious : bool):
	previousSocket = camera.activeSocket
	camera.BeginLerp("check handcuffs")
	await get_tree().create_timer(.6, false).timeout
	animator_handcuffsPlayer.play("check handcuffs")
	await get_tree().create_timer(.8, false).timeout
	if (lerpingToPrevious): camera.BeginLerp(previousSocket)
	
func BreakPlayerHandCuffs(lerpingToPrevious : bool):
	previousSocket = camera.activeSocket
	camera.BeginLerp("check handcuffs")
	await get_tree().create_timer(.6, false).timeout
	animator_handcuffsPlayer.play("player break handcuffs")
	await get_tree().create_timer(.8, false).timeout
	if (lerpingToPrevious): camera.BeginLerp(previousSocket)
	
func CheckPlayerHandCuffs_Animation():
	previousSocket = camera.activeSocket
	camera.BeginLerp("check handcuffs")
	await get_tree().create_timer(.6, false).timeout
	animator_handcuffsPlayer.play("check handcuffs")
	await get_tree().create_timer(.8, false).timeout
	camera.BeginLerp(previousSocket)

func RemoveAllCuffsRoutine():
	if (roundManager.dealerCuffed):
		camera.BeginLerp("enemy cuffs close")
		await get_tree().create_timer(.3, false).timeout
		dealerAI.animator_dealerHands.play("dealer break cuffs")
		dealerAI.speaker_breakHandcuffs.play()
		dealerAI.dealerAboutToBreakFree = false
		roundManager.dealerCuffed = false
		await get_tree().create_timer(.47, false).timeout
	if (roundManager.playerCuffed):
		camera.BeginLerp("check handcuffs")
		await get_tree().create_timer(.6, false).timeout
		animator_handcuffsPlayer.play("player break handcuffs")
		roundManager.playerCuffed = false
		roundManager.playerAboutToBreakFree = false
		await get_tree().create_timer(.8, false).timeout
	pass
