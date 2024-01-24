class_name ShellSpawner extends Node

@export var dialogue : Dialogue
@export var anim_compartment : AnimationPlayer
@export var roundManager : RoundManager
@export var camera : CameraManager
@export var shellInstance : PackedScene
@export var shellLocationArray : Array[Vector3]
@export var spawnParent : Node3D
@export var healthCounter : HealthCounter
@export var soundArray_latchOpen : Array[AudioStream]
@export var speaker_latchOpen : AudioStreamPlayer2D
@export var speaker_audioIndicator : AudioStreamPlayer2D
@export var soundArray_indicators : Array[AudioStream]

var spawnedShell
var locationIndex
var tempSequence : Array[String]
var sequenceArray : Array[String]
var shellBranch : ShellClass
var spawnedShellObjectArray = []

func _ready():
	pass


func _process(delta):
	pass

var skipDialoguePresented = false
func MainShellRoutine():
	if (roundManager.playerData.currentBatchIndex != 0):
		roundManager.shellLoadingSpedUp = true
	#CLEAR PREVIOUS SHELL SEQUENCE ARRAY
	sequenceArray = []
	#CHECK IF CONSOLE TEXT EXISTS. SHOW CONSOLE TEXT
	
	#INITIAL CAMERA SOCKET. HEALTH COUNTER FUNCTIONALITY
	if (roundManager.roundArray[roundManager.currentRound].bootingUpCounter):
		camera.BeginLerp("health counter")
		await get_tree().create_timer(.5, false).timeout
		healthCounter.Bootup()
		await get_tree().create_timer(1.4, false).timeout
	#await get_tree().create_timer(2, false).timeout #NEW
	camera.BeginLerp("shell compartment")
	await get_tree().create_timer(.5, false).timeout
	#SHELL SPAWNING
	var temp_nr = roundManager.roundArray[roundManager.currentRound].amountBlank + roundManager.roundArray[roundManager.currentRound].amountLive
	var temp_live = roundManager.roundArray[roundManager.currentRound].amountLive
	var temp_blank = roundManager.roundArray[roundManager.currentRound].amountBlank
	var temp_shuf = roundManager.roundArray[roundManager.currentRound].shufflingArray
	SpawnShells(temp_nr, temp_live, temp_blank, temp_shuf)
	seq = sequenceArray
	anim_compartment.play("show shells")
	PlayLatchSound()
	PlayAudioIndicators()
	await get_tree().create_timer(1, false).timeout
	roundManager.ignoring = false
	#DIALOGUE
	var text_lives
	var text_blanks
	if (temp_live == 1): text_lives = "LIVE ROUND."
	else: text_lives = "LIVE ROUNDS."
	if (temp_blank == 1): text_blanks = "BLANK."
	else: text_blanks = "BLANKS."
	var finalstring : String = str(temp_live) + " " + text_lives + " " + str(temp_blank) + " " + text_blanks
	var maindur = 1.3
	if (roundManager.playerData.currentBatchIndex == 2):
		roundManager.playerData.skippingShellDescription = true
	if (!roundManager.playerData.skippingShellDescription): dialogue.ShowText_Forever(finalstring)
	if (roundManager.playerData.skippingShellDescription && !skipDialoguePresented):
		dialogue.ShowText_Forever("YOU KNOW THE DRILL.")
		maindur = 2.5
		skipDialoguePresented = true
	if(!roundManager.playerData.skippingShellDescription): await get_tree().create_timer(2.5, false).timeout
	else: await get_tree().create_timer(maindur, false).timeout
	dialogue.HideText()
	#HIDE SHELLS
	anim_compartment.play("hide shells")
	PlayLatchSound()
	if(roundManager.shellLoadingSpedUp): await get_tree().create_timer(.2, false).timeout
	else: await get_tree().create_timer(.5, false).timeout
	#CHECK IF INSERTING INTO CHAMBER IN RANDOM ORDER.
	if (roundManager.roundArray[roundManager.currentRound].insertingInRandomOrder):
		sequenceArray.shuffle()
		sequenceArray.shuffle()
	roundManager.LoadShells()
	return
	pass

func SpawnShells(numberOfShells : int, numberOfLives : int, numberOfBlanks : int, shufflingArray : bool):
	#DELETE PREVIOUS SHELLS
	for i in range(spawnedShellObjectArray.size()):
		spawnedShellObjectArray[i].queue_free()
	spawnedShellObjectArray = []
	
	#SETUP SHELL ARRAY
	sequenceArray = []
	tempSequence = []
	for i in range(numberOfLives):
		tempSequence.append("live")
	for i in range(numberOfBlanks):
		tempSequence.append("blank")
	if (shufflingArray):
		tempSequence.shuffle()
	for i in range(tempSequence.size()):
		sequenceArray.append(tempSequence[i])
		pass
	
	locationIndex = 0
	#SPAWN SHELLS
	for i in range(numberOfShells):
		spawnedShell = shellInstance.instantiate()
		shellBranch = spawnedShell.get_child(0)
		if (sequenceArray[i] == "live"): shellBranch.isLive = true
		else: shellBranch.isLive = false
		shellBranch.ApplyStatus()
		spawnParent.add_child(spawnedShell)
		spawnedShell.transform.origin = shellLocationArray[locationIndex]
		spawnedShell.rotation_degrees = Vector3(-90, -90, 180)
		spawnedShellObjectArray.append(spawnedShell)
		locationIndex += 1
		pass
	pass

var tog = false
func PlayLatchSound():
	tog = !tog
	if (tog): speaker_latchOpen.stream = soundArray_latchOpen[0]
	else: speaker_latchOpen.stream = soundArray_latchOpen[1]
	speaker_latchOpen.play()

var seq = []
func PlayAudioIndicators():
	await get_tree().create_timer(.37, false).timeout
	for i in range(seq.size()):
		if (seq[i] == "blank"): speaker_audioIndicator.stream = soundArray_indicators[0]
		else: speaker_audioIndicator.stream = soundArray_indicators[1]
		speaker_audioIndicator.play()
		await get_tree().create_timer(.07, false).timeout















