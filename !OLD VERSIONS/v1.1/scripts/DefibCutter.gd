class_name DefibCutter extends Node

@export var cam : CameraManager
@export var dia : Dialogue
@export var animator_main : AnimationPlayer
@export var consoleArray : Array[Node3D]
@export var speaker_motor : AudioStreamPlayer2D
@export var speaker_bootup : AudioStreamPlayer2D
@export var speaker_beep : AudioStreamPlayer2D
@export var speaker_blademove : AudioStreamPlayer2D
@export var blade_player : DefibBlade
@export var blade_dealer : DefibBlade
@export var roundManager : RoundManager
@export var errorUI_player : Node3D
@export var errorUI_dealer : Node3D
@export var speaker_error : AudioStreamPlayer2D
@export var soundArray_error : Array[AudioStream]
@export var healthUI_player : Node3D
@export var healthUI_dealer : Node3D
@export var healthUI_divider : Node3D

var cutDialogueSent = false

func InitialSetup():
	cam.BeginLerp("defib setup")
	await get_tree().create_timer(.6, false).timeout
	animator_main.play("initial setup")
	speaker_motor.play()
	await get_tree().create_timer(3.6, false).timeout
	cam.BeginLerp("defib console")
	speaker_bootup.play()
	await get_tree().create_timer(1.9, false).timeout
	for i in range(consoleArray.size()):
		consoleArray[i].visible = true
		speaker_beep.pitch_scale = randf_range(.8, 1.0)
		speaker_beep.play()
		await get_tree().create_timer(.09, false).timeout
	await get_tree().create_timer(.4, false).timeout
	cam.BeginLerp("defib setup")
	await get_tree().create_timer(.6, false).timeout
	blade_player.Blade("open", true)
	blade_dealer.Blade("open", false)
	await get_tree().create_timer(.5, false).timeout
	animator_main.play("main setup")
	speaker_blademove.play()
	await get_tree().create_timer(.6, false).timeout
	cam.BeginLerp("defib blade insert")
	await get_tree().create_timer(1.8, false).timeout
	cam.BeginLerp("home")
	await get_tree().create_timer(.6, false).timeout

func CutWire(who : String):
	var tempwho = who
	var origsocket = cam.activeSocket
	cam.BeginLerp("enemy")
	await get_tree().create_timer(3, false).timeout
	if (!cutDialogueSent):
		dia.ShowText_Forever("ARE YOU READY?")
		await get_tree().create_timer(4, false).timeout
		dia.HideText()
		await get_tree().create_timer(.2, false).timeout
		cutDialogueSent = true
	cam.BeginLerp("defib blade insert")
	await get_tree().create_timer(1, false).timeout
	if (who == "player"): blade_player.Blade("close", true)
	if (who == "dealer"): blade_dealer.Blade("close", true)
	roundManager.requestedWireCut = false
	roundManager.wireToCut = ""
	await get_tree().create_timer(.05, false).timeout
	BreakDisplay(tempwho)
	await get_tree().create_timer(.8, false).timeout
	cam.BeginLerp("health counter")
	await get_tree().create_timer(.6, false).timeout
	FlashError(tempwho)
	await get_tree().create_timer(.8, false).timeout
	cam.BeginLerp(origsocket)
	await get_tree().create_timer(1, false).timeout

#.36
func FlashError(who : String):
	var act = null
	if (who == "player"): act = errorUI_player
	else: act = errorUI_dealer
	act.visible = true
	PlayError()
	await get_tree().create_timer(.05, false).timeout
	act.visible = false
	await get_tree().create_timer(.05, false).timeout
	act.visible = true
	PlayError()
	await get_tree().create_timer(.11, false).timeout
	act.visible = false
	await get_tree().create_timer(.05, false).timeout
	act.visible = true
	PlayError()
	await get_tree().create_timer(.05, false).timeout
	act.visible = false
	PlayError()

func BlipError(who : String):
	var act = null
	if (who == "player"): act = errorUI_player
	else: act = errorUI_dealer
	act.visible = true
	PlayError()
	await get_tree().create_timer(.05, false).timeout
	act.visible = false
	await get_tree().create_timer(.05, false).timeout
	act.visible = true
	PlayError()
	await get_tree().create_timer(.11, false).timeout
	act.visible = false
	PlayError()

func BlipError_Both():
	errorUI_dealer.visible = true
	errorUI_player.visible = true
	PlayError()
	await get_tree().create_timer(.05, false).timeout
	errorUI_dealer.visible = false
	errorUI_player.visible = false
	await get_tree().create_timer(.05, false).timeout
	errorUI_dealer.visible = true
	errorUI_player.visible = true
	PlayError()
	await get_tree().create_timer(.11, false).timeout
	errorUI_dealer.visible = false
	errorUI_player.visible = false
	PlayError()

var displayBroken_player = false
var displayBroken_dealer = false
func BreakDisplay(who : String):
	if (who == "player"):
		healthUI_player.visible = false
		displayBroken_player = true
	else:
		healthUI_dealer.visible = false
		displayBroken_dealer = true
	if (displayBroken_dealer && displayBroken_player):
		healthUI_divider.visible = false

func PlayError():
	var index = randi_range(0, soundArray_error.size() - 1)
	var s = soundArray_error[index]
	speaker_error.stream = s
	speaker_error.play()














