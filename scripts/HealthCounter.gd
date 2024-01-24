class_name HealthCounter extends Node

@export var ui_playerwin : Label3D
@export var defibCutter : DefibCutter
@export var roundManager : RoundManager
@export var symbolArray_player : Array[MeshInstance3D]
@export var symbolArray_enemy : Array[MeshInstance3D]
@export var uiparent : Node3D
@export var ui_playername : Label3D
@export var uiArray : Array[Node3D]
@export var speaker_bootup : AudioStreamPlayer3D
@export var speaker_beep : AudioStreamPlayer3D
@export var speaker_noise : AudioStreamPlayer3D
@export var camera : CameraManager
@export var animator_flickerEnemy : AnimationPlayer
@export var animator_flickerPlayer : AnimationPlayer
@export var animator_playerHands : AnimationPlayer
@export var animator_dealerHands : AnimationPlayer
@export var dialogue : Dialogue
@export var speaker_truedeath : AudioStreamPlayer2D
@export var skullSymbols : Array[VisualInstance3D]

var dialogueEntered_player = false
var dialogueEntered_dealer = false

func _ready():
	ClearDisplay()
	pass

var setting = true
func SetupHealth():
	if (roundManager.roundArray[roundManager.currentRound].isFirstRound):
		if (setting):
			ui_playername.text = roundManager.playerData.playername.to_upper()
			ui_playerwin.text = roundManager.playerData.playername.to_upper() + " WINS!"
			setting = false
		roundManager.health_player = roundManager.roundArray[roundManager.currentRound].startingHealth
		roundManager.health_opponent = roundManager.roundArray[roundManager.currentRound].startingHealth
		dialogueEntered_player = false
		dialogueEntered_dealer = false

func UpdateDisplay():
	for i in range(symbolArray_player.size()):
		if (i <= roundManager.health_player):
			symbolArray_player[i].visible = true
		else: symbolArray_player[i].visible = false
	for i in range(symbolArray_enemy.size()):
		if (i <= roundManager.health_opponent):
			symbolArray_enemy[i].visible = true
		else: symbolArray_enemy[i].visible = false
	FlickerLastDigit()
	pass

func FlickerLastDigit():
	if (roundManager.health_player == 1): animator_flickerPlayer.play("flicker digit")
	else: animator_flickerPlayer.play("RESET")
	if (roundManager.health_opponent == 1): animator_flickerEnemy.play("flicker digit")
	else: animator_flickerEnemy.play("RESET")

var playerShotSelf = false
var trueDeathSetup = false
var checkingPlayer = false
func UpdateDisplayRoutine(isRaisingHealth : bool, goingToPreviousSocket : bool, showPlayerWin : bool):
	var indicating = true
	if (roundManager.dealerCuffed && playerShotSelf): 
		roundManager.waitingForHealthCheck = true
		playerShotSelf = false
	if (showPlayerWin):
		#ERROR - FLICKER BOTH HERE
		camera.BeginLerp("health counter")
		await get_tree().create_timer(.8, false).timeout
		UpdateDisplay()
		speaker_noise.play()
		return
	var previousSocket = camera.activeSocket
	camera.BeginLerp("health counter")
	await get_tree().create_timer(.8, false).timeout
	UpdateDisplay()
	if (checkingPlayer && defibCutter.displayBroken_player): 
		indicating = false
		defibCutter.BlipError("player")
	if (!checkingPlayer && defibCutter.displayBroken_dealer): 
		indicating = false
		defibCutter.BlipError("dealer")
	if (indicating):
		if (isRaisingHealth): speaker_beep.play()
		else: speaker_noise.play()
	if ((roundManager.health_opponent <= 2 or roundManager.health_player <= 2) && roundManager.playerData.currentBatchIndex == 2 && !roundManager.endless):
		if (roundManager.defibCutterReady && !trueDeathSetup): 
			#roundManager.musicManager.EndTrack()
			speaker_truedeath.play()
			trueDeathSetup = true
		if (roundManager.health_opponent <= 2 && !roundManager.wireIsCut_dealer): 
			roundManager.wireToCut = "dealer"
			roundManager.requestedWireCut = true
			roundManager.wireIsCut_dealer = true
			roundManager.health_opponent = 1
		if (roundManager.health_player <= 2 && !roundManager.wireIsCut_player): 
			roundManager.wireToCut = "player" 
			roundManager.requestedWireCut = true
			roundManager.wireIsCut_player = true
			roundManager.health_player = 1
	#if (roundManager.shellSpawner.sequenceArray[0] == null): await get_tree().create_timer(.8, false).timeout
	await get_tree().create_timer(.7, false).timeout
	if (roundManager.health_player == 1 && !dialogueEntered_player && !roundManager.wireIsCut_player):
		if (!roundManager.wireIsCut_player): dialogue.ShowText_ForDuration("CAREFUL, NOW ...", 3)
		else: dialogue.ShowText_ForDuration("OH MY ...", 3)
		await get_tree().create_timer(3, false).timeout
		dialogueEntered_player = true
	var lerpingCamera = true
	if (roundManager.shellSpawner.sequenceArray.size() == 0): 
		#lerpingCamera = false
		pass
	if (lerpingCamera):
		if (goingToPreviousSocket): camera.BeginLerp(previousSocket)
		else: camera.BeginLerp("home")
	await get_tree().create_timer(.4, false).timeout

#why can I not add functions with arguments into godot animator :sob:
func UpdateDisplayRoutineCigarette_Enemy():
	var maxHealth = roundManager.roundArray[0].startingHealth
	var changingHealth = false
	var prevhealth = roundManager.health_opponent
	if (!roundManager.wireIsCut_dealer): roundManager.health_opponent += 1
	if (roundManager.health_opponent > maxHealth): roundManager.health_opponent = maxHealth
	var newhealth = roundManager.health_opponent
	if (newhealth != prevhealth): changingHealth = true
	UpdateDisplayRoutineCigarette_Main(changingHealth, true)
	pass

func UpdateDisplayRoutineCigarette_Player():
	var maxHealth = roundManager.roundArray[0].startingHealth
	var changingHealth = false
	var prevhealth = roundManager.health_player
	if (!roundManager.wireIsCut_player): roundManager.health_player += 1
	if (roundManager.health_player > maxHealth): roundManager.health_player = maxHealth
	var newhealth = roundManager.health_player
	if (newhealth != prevhealth): changingHealth = true
	UpdateDisplayRoutineCigarette_Main(changingHealth, false)
	pass

func UpdateDisplayRoutineCigarette_Main(isChanging : bool, isAddingEnemy : bool):
	var prevsocket = camera.activeSocket
	var playingsound = true
	camera.BeginLerp("health counter")
	await get_tree().create_timer(.8, false).timeout
	if (isAddingEnemy && defibCutter.displayBroken_dealer):
		defibCutter.BlipError("dealer")
		playingsound = false
	if (!isAddingEnemy && defibCutter.displayBroken_player):
		defibCutter.BlipError("player")
		playingsound = false
	UpdateDisplay()
	if (isChanging && playingsound): speaker_beep.play()
	await get_tree().create_timer(.7, false).timeout
	if (!isAddingEnemy): 
		camera.BeginLerp("home")
		animator_playerHands.play("player revert cigarette")
	else: 
		camera.BeginLerp("enemy")
		animator_dealerHands.play("RESET")
	pass

func SwapSkullSymbols():
	for sym in skullSymbols:
		sym.set_layer_mask_value(1, true)
		sym.get_parent().set_layer_mask_value(1, false)

#orig .13
var settingUpBroken = false
func Bootup():
	speaker_bootup.play()
	#uiparent.visible = true
	ClearDisplay()
	for i in range(uiArray.size()):
		uiArray[i].visible = true
	await get_tree().create_timer(.85, false).timeout
	if (roundManager.playerData.currentBatchIndex == 2 && !settingUpBroken && !roundManager.endless):
		speaker_beep.pitch_scale = .09
		SwapSkullSymbols()
		settingUpBroken = true
	speaker_beep.play()
	UpdateDisplay()
	pass

func ClearDisplay():
	for i in range(symbolArray_player.size()):
		symbolArray_player[i].visible = false
	for i in range(symbolArray_enemy.size()):
		symbolArray_enemy[i].visible = false

func DisableCounter():
	for i in range(uiArray.size()):
		uiArray[i].visible = false
	#uiparent.visible = false
