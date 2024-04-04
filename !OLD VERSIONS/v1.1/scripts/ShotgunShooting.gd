class_name ShotgunShooting extends Node

@export var ejectionManager_player : ShellEjectManager
@export var cursorManager : CursorManager
@export var shotgunIndicator : PickupIndicator
@export var roundManager : RoundManager
@export var shellSpawner : ShellSpawner
@export var collider_shotgun : StaticBody3D
@export var decisionText : DecisionTextManager
@export var shotgunshaker : ObjectShaker
@export var perm : PermissionManager
@export var animator_shotgun : AnimationPlayer
@export var camera : CameraManager
@export var speaker_live : AudioStreamPlayer2D
@export var speaker_blank : AudioStreamPlayer2D
@export var healthCounter : HealthCounter
@export var animator_muzzleFlash : AnimationPlayer
@export var animator_muzzleFlash_model : AnimationPlayer
@export var cameraShaker : CameraShaker
@export var death : DeathManager
@export var smoke : SmokeController
@export var speakerArray_pitchShift : Array[SpeakerController]
@export var speakerArray_pitchShift3D : Array[SpeakerController3D]
@export var timescale : TimeScaleManager
@export var splatters : Array[CompressedTexture2D]
@export var mat_splatter : GeometryInstance3D
@export var speaker_splatter : AudioStreamPlayer2D
@export var anim_splatter : AnimationPlayer

var playerCanGoAgain

func GrabShotgun():
	perm.SetIndicators(false)
	perm.SetInteractionPermissions(false)
	perm.RevertDescriptionUI()
	ShotgunCollider(false)
	animator_shotgun.play("player grab shotgun")
	shotgunshaker.StartShaking()
	decisionText.SetUI(true)
	await get_tree().create_timer(.5, false).timeout

var disablingDelayShit = false
var dealerShotTrue = false

func MainSlowDownRoutine(whoCopy : String, fromDealer : bool):
	var who = whoCopy
	var currentRoundInChamber = shellSpawner.sequenceArray[0]
	var healthAfterShot = 1
	if (!fromDealer):
		healthAfterShot = roundManager.health_opponent - roundManager.currentShotgunDamage
		if (healthAfterShot < 0): healthAfterShot = 0
	else: if(roundManager.health_opponent == 0): healthAfterShot = 0
	if (currentRoundInChamber == "live" && who == "dealer" && healthAfterShot == 0): 
		#TIME SCALE SHIFT
		for i in range(speakerArray_pitchShift.size()):
			speakerArray_pitchShift[i].fadeDuration_pitch = timescale.pitchShiftDuration
			speakerArray_pitchShift[i].BeginPitchShift(speakerArray_pitchShift[i].lowestPitchValue, speakerArray_pitchShift[i].originalPitch)
		for i in range(speakerArray_pitchShift3D.size()):
			speakerArray_pitchShift3D[i].fadeDuration_pitch = timescale.pitchShiftDuration
			speakerArray_pitchShift3D[i].BeginPitchShift(speakerArray_pitchShift3D[i].lowestPitchValue, speakerArray_pitchShift3D[i].originalPitch)
		timescale.BeginTimeScaleLerp(.2, 1.0)
		BloodSplatter()


func BloodSplatter():
	await get_tree().create_timer(.17, false).timeout
	speaker_splatter.pitch_scale = randf_range(.3, .5)
	speaker_splatter.play()
	anim_splatter.play("fade out")
	mat_splatter.material_override.set("albedo_texture", splatters[0])
	await get_tree().create_timer(.08, false).timeout
	mat_splatter.material_override.set("albedo_texture", splatters[1])
	await get_tree().create_timer(.08, false).timeout
	mat_splatter.material_override.set("albedo_texture", splatters[2])
	await get_tree().create_timer(.08, false).timeout
	mat_splatter.material_override.set("albedo_texture", splatters[3])
	pass

func Shoot(who : String):
	dealerShotTrue = false
	disablingDelayShit = false
	playerCanGoAgain = false
	var playerDied = false
	var dealerShot = false
	ejectionManager_player.FadeOutShell()
	cursorManager.SetCursor(false, false)
	#CAMERA CONTROLS & ANIMATION DEPENDING ON WHO IS SHOT
	match(who):
		"self":
			await get_tree().create_timer(.25, false).timeout
			animator_shotgun.play("player shoot self")
			await get_tree().create_timer(.5, false).timeout
			camera.BeginLerp("enemy")
		"dealer":
			await get_tree().create_timer(.25, false).timeout
			animator_shotgun.play("player shoot dealer")
			await get_tree().create_timer(.5, false).timeout
			camera.BeginLerp("enemy")
	#PLAY CORRECT SOUND. ASSIGN CURRENT ROUND IN CHAMBER
	await get_tree().create_timer(2, false).timeout
	var currentRoundInChamber = shellSpawner.sequenceArray[0]	
	MainSlowDownRoutine(who, false)
	if (who == "self"): whoshot = "player"
	else: whoshot = "dealer"
	PlayShootingSound()
	#SHAKE CAMERA
	if (currentRoundInChamber == "live"):
		smoke.SpawnSmoke("barrel")
		cameraShaker.Shake()
	#SUBTRACT HEALTH. ASSIGN PLAYER CAN GO AGAIN. RETURN IF DEAD
	if (currentRoundInChamber == "live" && who == "dealer"): 
		roundManager.health_opponent -= roundManager.currentShotgunDamage
		if (roundManager.health_opponent < 0): roundManager.health_opponent = 0
	if (currentRoundInChamber == "live" && who == "self"): 
		roundManager.waitingForHealthCheck2 = true
		if (shellSpawner.sequenceArray.size() == 1): 
			whatTheFuck = true
		roundManager.waitingForDealerReturn = true
		healthCounter.playerShotSelf = true
		playerDied = true
		roundManager.health_player -= roundManager.currentShotgunDamage
		if (roundManager.health_player < 0): roundManager.health_player = 0
		playerCanGoAgain = false
		healthCounter.checkingPlayer = true
		await(death.Kill("player", false, true))
	if (currentRoundInChamber == "blank" && who == "self"): playerCanGoAgain = true
	if (currentRoundInChamber == "live" && who == "dealer"): 
		playerCanGoAgain = false
		dealerShot = true
		dealerShotTrue = true
		await(death.Kill("dealer", false, false))
	if (playerDied): return
	if (dealerShot): return
	await get_tree().create_timer(.3, false).timeout
	#EJECTING SHELLS
	if (currentRoundInChamber == "blank" && who == "self"):
		animator_shotgun.play("player eject shell")
		await get_tree().create_timer(.85, false).timeout
		camera.BeginLerp("home")
		await get_tree().create_timer(1.35, false).timeout
		FinalizeShooting(playerCanGoAgain, true, false, false)
		return
	if (currentRoundInChamber == "blank" && who == "dealer"): disablingDelayShit = true
	ShootingDealerEjection(currentRoundInChamber, who, false)

func ShootingDealerEjection(currentRoundInChamberCopy : String, whoCopy : String, hasDelay : bool):
	if ((currentRoundInChamberCopy == "blank" or currentRoundInChamberCopy == "live") && whoCopy == "dealer"):
		animator_shotgun.play("player eject shell2")
		await get_tree().create_timer(2, false).timeout
	if (hasDelay): await get_tree().create_timer(2.5, false).timeout
	if (!disablingDelayShit): 
		FinalizeShooting(playerCanGoAgain, true, true, false)
	else: 
		FinalizeShooting(playerCanGoAgain, true, false, false)

var whatTheFuck = false
var delaying = false
var isPlayerSide = false
func FinalizeShooting(playerCanGoAgain : bool, placeShotgunOnTable : bool, waitForRevival : bool, addDelay : bool):
	if(placeShotgunOnTable): animator_shotgun.play("player place on table after eject")
	shotgunshaker.StopShaking()
	#shellSpawner.sequenceArray.remove_at(0)
	await get_tree().create_timer(.6, false).timeout
	shotgunIndicator.Revert()
	ShotgunCollider(true)
	if (death.shitIsFuckedUp): await get_tree().create_timer(3, false).timeout
	if (waitForRevival): await get_tree().create_timer(2, false).timeout
	if (addDelay): await get_tree().create_timer(3, false).timeout
	if (delaying): await get_tree().create_timer(4, false).timeout
	if (whatTheFuck): await get_tree().create_timer(2, false).timeout
	whatTheFuck = false
	#delaying = false
	if (roundManager.shellSpawner.sequenceArray.size() == 0 && dealerShotTrue): await get_tree().create_timer(2, false).timeout
	#abc
	if ((roundManager.health_opponent <= 2 or roundManager.health_player <= 2) && roundManager.playerData.currentBatchIndex == 2 && !roundManager.endless):
		if (roundManager.health_opponent <= 2 && !roundManager.wireIsCut_dealer):
			await get_tree().create_timer(2, false).timeout
		if (roundManager.health_player <= 2 && !roundManager.wireIsCut_player):
			await get_tree().create_timer(2, false).timeout
	if(roundManager.health_opponent != 0): roundManager.EndTurn(playerCanGoAgain)

func PlayShootingSound():
	var currentRoundInChamber = shellSpawner.sequenceArray[0]
	if (currentRoundInChamber == "live"):
		CheckIfFinalShot()
		speaker_live.play()
		roundManager.playerData.stat_shotsFired += 1
		animator_muzzleFlash.play("muzzle flash fire")
		animator_muzzleFlash_model.play("fire")
	else: speaker_blank.play()
	pass

var fired = false
var temphealth_dealer
var temphealth_player
var whoshot = ""
func CheckIfFinalShot():
	temphealth_dealer = roundManager.health_opponent - roundManager.currentShotgunDamage
	temphealth_player = roundManager.health_player - roundManager.currentShotgunDamage
	if (!fired && roundManager.playerData.currentBatchIndex == 2 && !roundManager.endless):
		if (temphealth_player <= 2 && whoshot == "player"):
			roundManager.musicManager.EndTrack()
			fired = true
		if (temphealth_dealer <= 2 && whoshot == "dealer"):
			roundManager.musicManager.EndTrack()
			fired = true

func ShotgunCollider(isEnabled : bool):
	if (isEnabled):
		collider_shotgun.collision_layer = 1
		collider_shotgun.collision_mask = 1
	else:
		collider_shotgun.collision_layer = 0
		collider_shotgun.collision_mask = 0
