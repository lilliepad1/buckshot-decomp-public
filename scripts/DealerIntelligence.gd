class_name DealerIntelligence extends Node
#ALTHOUGH THE CLASS NAME SUGGESTS THAT THE DEALER HAS INTELLIGENCE, AND IT'S TRUE THERE ARE MANY INTELLIGENT DEALERS,
#CONTRARY TO THOSE THIS ONE IS NOT. HERE THERE IS NO INTELLIGENCE. ONLY LAYERS, HEAPS AND CLUMPS OF SPAGHETTI JUMBLE CODE.

@export var hands : HandManager
@export var itemManager : ItemManager
@export var shellSpawner : ShellSpawner
@export var shellLoader : ShellLoader
@export var shotgunShooting : ShotgunShooting
@export var roundManager : RoundManager
@export var animator_shotgun : AnimationPlayer
@export var animator_dealerHands : AnimationPlayer
@export var camera : CameraManager
@export var ejectManager : ShellEjectManager
@export var healthCounter : HealthCounter
@export var death : DeathManager
@export var cameraShaker : CameraShaker
@export var smoke : SmokeController
@export var shellEject_dealer : ShellEjectManager
@export var speaker_dealerarrive : AudioStreamPlayer2D
@export var speaker_handCrack : AudioStreamPlayer2D
@export var soundArray_cracks : Array[AudioStream]
@export var speaker_checkHandcuffs : AudioStreamPlayer2D
@export var speaker_breakHandcuffs : AudioStreamPlayer2D
@export var speaker_giveHandcuffs : AudioStreamPlayer2D
@export var sound_dealerarrive : AudioStream
@export var sound_dealerarriveCuffed : AudioStream
@export var dealermesh_normal : VisualInstance3D
@export var dealermesh_crushed : VisualInstance3D

var dealerItemStringArray : Array[String]
var dealerAboutToBreakFree = false
var dealerCanGoAgain = false
var dealerHoldingShotgun = false

func DealerCheckHandCuffs():
	var brokeFree = false
	camera.BeginLerp("enemy cuffs close")
	if (!dealerAboutToBreakFree):
		await get_tree().create_timer(.3, false).timeout
		speaker_checkHandcuffs.play()
		animator_dealerHands.play("dealer check handcuffs")
		await get_tree().create_timer(.7, false).timeout
		brokeFree = false
	else:
		await get_tree().create_timer(.3, false).timeout
		animator_dealerHands.play("dealer break cuffs") #replace with broke free anim
		speaker_breakHandcuffs.play()
		#await get_tree().create_timer(.7, false).timeout
		brokeFree = true
		roundManager.dealerCuffed = false
		dealerAboutToBreakFree = false
	dealerAboutToBreakFree = true
	roundManager.ReturnFromCuffCheck(brokeFree)

func Animator_CheckHandcuffs():
	speaker_checkHandcuffs.play()

func Animator_GiveHandcuffs():
	speaker_giveHandcuffs.play()

func BeginDealerTurn():
	mainLoopFinished = false
	usingHandsaw = false
	DealerChoice()

var dealerTarget = ""
var knownShell = ""
var dealerKnowsShell = false
var mainLoopFinished = false
var usingHandsaw = false
var dealerUsedItem = false
func DealerChoice():
	var dealerWantsToUse = ""
	var dealerFinishedUsingItems = false
	var hasHandsaw = false
	if (roundManager.requestedWireCut):
		await(roundManager.defibCutter.CutWire(roundManager.wireToCut))
	if (shellSpawner.sequenceArray.size() == 0):
		roundManager.StartRound(true)
		return
	if (roundManager.shellSpawner.sequenceArray.size() == 1):
		knownShell = shellSpawner.sequenceArray[0]
		if (shellSpawner.sequenceArray[0] == "live"): knownShell = "live" 
		else: knownShell = "blank"
		if (knownShell == "live"): dealerTarget = "player"
		else: dealerTarget = "self"
		dealerKnowsShell = true
	for i in range(itemManager.itemArray_dealer.size()):
		if (itemManager.itemArray_dealer[i] == "magnifying glass" && !dealerKnowsShell && shellSpawner.sequenceArray.size() != 1):
			dealerWantsToUse = "magnifying glass"
			if (shellSpawner.sequenceArray[0] == "live"): knownShell = "live" 
			else: knownShell = "blank"
			if (knownShell == "live"): dealerTarget = "player"
			else: dealerTarget = "self"
			dealerKnowsShell = true
			break
		if (itemManager.itemArray_dealer[i] == "cigarettes"):
			var breaking = false
			if (roundManager.health_opponent < roundManager.roundArray[0].startingHealth):
				dealerWantsToUse = "cigarettes"
				breaking = true
			if (breaking): break
		if (itemManager.itemArray_dealer[i] == "beer" && knownShell != "live" && shellSpawner.sequenceArray.size() != 1):
			dealerWantsToUse = "beer"
			shellEject_dealer.FadeOutShell()
			break
		if (itemManager.itemArray_dealer[i] == "handcuffs" && roundManager.playerCuffed == false && shellSpawner.sequenceArray.size() != 1):
			dealerWantsToUse = "handcuffs"
			roundManager.playerCuffed = true
			break
		if (itemManager.itemArray_dealer[i] == "handsaw" && !roundManager.barrelSawedOff && knownShell == "live"):
			dealerWantsToUse = "handsaw"
			usingHandsaw = true
			roundManager.barrelSawedOff = true
			roundManager.currentShotgunDamage = 2
			break
	
	if (dealerWantsToUse == ""): mainLoopFinished = true
	for i in range(itemManager.itemArray_dealer.size()):
		if (itemManager.itemArray_dealer[i] == "handsaw"): hasHandsaw = true
	if (mainLoopFinished && !usingHandsaw && hasHandsaw && !roundManager.barrelSawedOff && knownShell != "blank"):
		var decision = CoinFlip()
		if (decision == 0): dealerTarget = "self"
		else: 
			dealerUsedItem = true
			dealerTarget = "player"
			dealerWantsToUse = "handsaw"
			usingHandsaw = true
			roundManager.barrelSawedOff = true
			roundManager.currentShotgunDamage = 2
		
	if (dealerWantsToUse != ""): 
		if (dealerHoldingShotgun):
			animator_shotgun.play("enemy put down shotgun")
			shellLoader.DealerHandsDropShotgun()
			dealerHoldingShotgun = false
			await get_tree().create_timer(.45, false).timeout
		dealerUsedItem = true
		if (roundManager.waitingForDealerReturn):
			await get_tree().create_timer(1.8, false).timeout
			roundManager.waitingForDealerReturn = false
		await(hands.PickupItemFromTable(dealerWantsToUse))
		#if (dealerWantsToUse == "handcuffs"): await get_tree().create_timer(.8, false).timeout #additional delay for initial player handcuff check (continues outside animation)
		if (dealerWantsToUse == "cigarettes"): await get_tree().create_timer(1.1, false).timeout #additional delay for health update routine (called in aninator. continues outside animation)
		itemManager.itemArray_dealer.erase(dealerWantsToUse)
		itemManager.numberOfItemsGrabbed_enemy -= 1
		DealerChoice()
		return
	if (dealerWantsToUse == ""): dealerFinishedUsingItems = true
	if (roundManager.waitingForDealerReturn):
		await get_tree().create_timer(1.8, false).timeout
	if (!dealerHoldingShotgun && dealerFinishedUsingItems):
		GrabShotgun()
		await get_tree().create_timer(1.4 + .5 - 1, false).timeout
	await get_tree().create_timer(1, false).timeout
	if (dealerTarget == ""): ChooseWhoToShootRandomly()
	else: Shoot(dealerTarget)
	dealerTarget = ""
	knownShell = ""
	dealerKnowsShell = false
	pass

func EndDealerTurn(canDealerGoAgain : bool):
	dealerCanGoAgain = canDealerGoAgain
	#USINGITEMS: ASSIGN DEALER CAN GO AGAIN FROM ITEMS HERE
	#CHECK IF OUT OF HEALTH
	var outOfHealth_player = roundManager.health_player == 0
	var outOfHealth_enemy = roundManager.health_opponent == 0
	var outOfHealth = outOfHealth_player or outOfHealth_enemy
	if (outOfHealth):
		#if (outOfHealth_player): roundManager.OutOfHealth("player")
		if (outOfHealth_enemy):	roundManager.OutOfHealth("dealer")
		return

	if (!dealerCanGoAgain):
		EndTurnMain()
	else:
		if (shellSpawner.sequenceArray.size()):
			BeginDealerTurn()
		else:
			EndTurnMain()
	pass

func ChooseWhoToShootRandomly():
	var decision = CoinFlip()
	if (decision == 0): Shoot("self")
	else: Shoot("player")

func GrabShotgun():
	#await get_tree().create_timer(1, false).timeout
	#camera.BeginLerp("enemy")
	#await get_tree().create_timer(.8, false).timeout
	await(shellLoader.DealerHandsGrabShotgun())
	await get_tree().create_timer(.2, false).timeout
	animator_shotgun.play("grab shotgun_pointing enemy")
	dealerHoldingShotgun = true
	pass

func EndTurnMain():
	await get_tree().create_timer(.5, false).timeout
	camera.BeginLerp("home")
	if (dealerHoldingShotgun): 
		animator_shotgun.play("enemy put down shotgun")
		shellLoader.DealerHandsDropShotgun()
	dealerHoldingShotgun = false
	roundManager.EndTurn(true)

func Shoot(who : String):
	var currentRoundInChamber = shellSpawner.sequenceArray[0]
	dealerCanGoAgain = false
	var playerDied = false
	var dealerDied = false
	ejectManager.FadeOutShell()
	#ANIMATION DEPENDING ON WHO IS SHOT
	match(who):
		"self":
			await get_tree().create_timer(.2, false).timeout
			animator_shotgun.play("enemy shoot self")
			await get_tree().create_timer(2, false).timeout
			shotgunShooting.whoshot = "dealer"
			shotgunShooting.PlayShootingSound()
			pass
		"player":
			animator_shotgun.play("enemy shoot player")
			await get_tree().create_timer(2, false).timeout
			shotgunShooting.whoshot = "player"
			shotgunShooting.PlayShootingSound()
			pass
	#SUBTRACT HEALTH. ASSIGN DEALER CAN GO AGAIN. RETURN IF DEAD
	if (currentRoundInChamber == "live" && who == "self"): 
		roundManager.health_opponent -= roundManager.currentShotgunDamage
		if (roundManager.health_opponent < 0): roundManager.health_opponent = 0
		smoke.SpawnSmoke("barrel")
		cameraShaker.Shake()
		dealerCanGoAgain = false
		death.Kill("dealer", false, true)
		return
	if (currentRoundInChamber == "live" && who == "player"): 
		roundManager.health_player -= roundManager.currentShotgunDamage
		if (roundManager.health_player < 0): roundManager.health_player = 0
		cameraShaker.Shake()
		smoke.SpawnSmoke("barrel")
		await(death.Kill("player", false, false))
		playerDied = true
	if (currentRoundInChamber == "blank" && who == "self"): dealerCanGoAgain = true
	#EJECTING SHELLS
	await get_tree().create_timer(.4, false).timeout
	if (who == "player"): animator_shotgun.play("enemy eject shell_from player")
	if (who == "self"): animator_shotgun.play("enemy eject shell_from self")
	await get_tree().create_timer(1.7, false).timeout
	#shellSpawner.sequenceArray.remove_at(0)
	EndDealerTurn(dealerCanGoAgain)

func Speaker_DealerArrive():
	var p = randf_range(.9, 1.0)
	speaker_dealerarrive.pitch_scale = p
	speaker_dealerarrive.stream = sound_dealerarrive
	speaker_dealerarrive.play()
	
func Speaker_DealerArrive_Cuffed():
	var p = randf_range(.9, 1.0)
	speaker_dealerarrive.pitch_scale = p
	speaker_dealerarrive.stream = sound_dealerarriveCuffed
	speaker_dealerarrive.play()

func Speaker_HandCrack():
	var randindex = randi_range(0, soundArray_cracks.size() - 1)
	speaker_handCrack.stream = soundArray_cracks[randindex]
	speaker_handCrack.play()

var swapped = false
func SwapDealerMesh():
	if (!swapped):
		dealermesh_normal.set_layer_mask_value(1, false)
		dealermesh_crushed.set_layer_mask_value(1, true)
		swapped = true
	pass

func CoinFlip():
	var result = randi_range(0, 1)
	return result
	pass
