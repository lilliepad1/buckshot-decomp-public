class_name DeathManager extends Node

@export var viewblocker : ColorRect
@export var speakersToDisable : Array[SpeakerController]
@export var animator_playerDefib : AnimationPlayer
@export var defibParent : Node3D
@export var speaker_playerDefib : AudioStreamPlayer2D
@export var cameraShaker : CameraShaker
@export var healthCounter : HealthCounter
@export var animator_shotgun : AnimationPlayer
@export var ejectManager_player : ShellEjectManager
@export var ejectManager_dealer : ShellEjectManager
@export var shotgunShooting : ShotgunShooting
@export var animator_dealer : AnimationPlayer
@export var speaker_crash : AudioStreamPlayer3D
@export var dealerAI : DealerIntelligence
@export var animator_dealerHands : AnimationPlayer
@export var shellLoader : ShellLoader
@export var scene_death : PackedScene
@export var savefile : SaveFileManager
@export var filter : FilterController
@export var animator_pp : AnimationPlayer
@export var speaker_heartbeat : AudioStreamPlayer2D

func _ready():
	defibParent.visible = false

var shitIsFuckedUp = false
func Kill(who : String, trueDeath : bool, returningShotgun : bool):
	var dealerKilledSelf = false
	shitIsFuckedUp = false
	match(who):
		"player":
			if (trueDeath):
				pass
			else:
				await get_tree().create_timer(.08, false).timeout
				viewblocker.visible = true
				if (returningShotgun):
					var addingDelay = false
					animator_shotgun.play("RESET")
					ejectManager_player.DeathEjection()
					await get_tree().create_timer(2)
					if (shotgunShooting.roundManager.health_opponent == 1 or shotgunShooting.roundManager.health_player == 1): addingDelay = true
					#if (shellLoader.roundManager.shellSpawner.sequenceArray.size() != 0): shotgunShooting.delaying = true
					if (shotgunShooting.roundManager.health_player == 1): shitIsFuckedUp = true
					if (shotgunShooting.roundManager.health_player != 0): shotgunShooting.FinalizeShooting(shotgunShooting.playerCanGoAgain, false, true, addingDelay)
				DisableSpeakers()
				if (shotgunShooting.roundManager.health_player == 0):
					shotgunShooting.roundManager.OutOfHealth("player")
					return
				await get_tree().create_timer(.4, false).timeout
				speaker_playerDefib.play()
				await get_tree().create_timer(.85, false).timeout
				speaker_heartbeat.play()
				animator_pp.play("revival brightness")
				defibParent.visible = true
				animator_playerDefib.play("RESET")
				viewblocker.visible = false
				filter.BeginPan(filter.lowPassMaxValue, filter.lowPassDefaultValue)
				FadeInSpeakers()
				cameraShaker.Shake()
				await get_tree().create_timer(.6, false).timeout
				animator_playerDefib.play("remove defib device")
				await get_tree().create_timer(.4, false).timeout
				await(healthCounter.UpdateDisplayRoutine(false, !shotgunShooting.playerCanGoAgain, false))
				defibParent.visible = false
				pass
		"dealer":
			if (trueDeath):
				pass
			else:
				if (returningShotgun):
					dealerKilledSelf = true
					shotgunShooting.MainSlowDownRoutine("dealer", true)
					animator_shotgun.play("enemy return shotgun self")
					dealerAI.dealerHoldingShotgun = false	
					ejectManager_dealer.DeathEjection()
				animator_dealer.play("dealer fly away")
				animator_dealerHands.play("hide hands")
				dealerAI.SwapDealerMesh()
				shellLoader.shotgunHand_L.visible = false
				shellLoader.shotgunHand_R.visible = false
				shotgunShooting.roundManager.dealerAtTable = false
				await get_tree().create_timer(.4, false).timeout
				speaker_crash.play()
				if (!dealerKilledSelf):
					#player shot dealer. eject shell and end turn here.
					shotgunShooting.ShootingDealerEjection(shotgunShooting.shellSpawner.sequenceArray[0], "dealer", false)
					pass
				await get_tree().create_timer(1.8, false).timeout
				if(shotgunShooting.roundManager.health_opponent == 0):
					shotgunShooting.roundManager.OutOfHealth("dealer")
					healthCounter.UpdateDisplayRoutine(false, false, true)
					return
				if (shotgunShooting.roundManager.health_player == 0):
					shotgunShooting.roundManager.OutOfHealth("player")
					return
				if (dealerKilledSelf): healthCounter.checkingPlayer = true
				else: healthCounter.checkingPlayer = false
				await(healthCounter.UpdateDisplayRoutine(false, true, false))
				if (!shotgunShooting.roundManager.dealerCuffed): 
					animator_dealerHands.play("dealer hands on table")
					shotgunShooting.roundManager.waitingForDealerReturn = true
				else: 
					animator_dealerHands.play("dealer hands on table cuffed")
					shotgunShooting.roundManager.waitingForReturn = true
				animator_dealer.play("dealer return to table")
				await get_tree().create_timer(2, false).timeout
				if (dealerKilledSelf): dealerAI.EndDealerTurn(dealerAI.dealerCanGoAgain)

func MainDeathRoutine():
	var loadingHeaven = false
	if (shotgunShooting.roundManager.endless):
		await get_tree().create_timer(.5, false).timeout
		get_tree().change_scene_to_file("res://scenes/death.tscn")
		return
	if (shotgunShooting.roundManager.wireIsCut_player): 
		shotgunShooting.roundManager.playerData.enteringFromTrueDeath = true
		loadingHeaven = true
	shotgunShooting.roundManager.playerData.playerEnteringFromDeath = true
	savefile.SaveGame()
	await get_tree().create_timer(.5, false).timeout
	if (!loadingHeaven): get_tree().change_scene_to_file("res://scenes/death.tscn")
	else: get_tree().change_scene_to_file("res://scenes/heaven.tscn")
	pass

func DisableSpeakers():
	for i in range(speakersToDisable.size()):
		speakersToDisable[i].SnapVolume(false)

func FadeInSpeakers():
	for i in range(speakersToDisable.size()):
		speakersToDisable[i].fadeDuration = 3
		speakersToDisable[i].FadeIn()
		#if (i != 1):
		#	speakersToDisable[i].fadeDuration = 3
		#	speakersToDisable[i].FadeIn()
		#else:
		#	speakersToDisable[i].SnapVolume(true)
