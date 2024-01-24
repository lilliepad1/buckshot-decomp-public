class_name EndingManager extends Node

@export var roundManager : RoundManager
@export var pp : WorldEnvironment
@export var animator_cam : AnimationPlayer
@export var animator_backdrop : AnimationPlayer
@export var cam : CameraManager
@export var blockout : Array[Node3D]
@export var viewblocker : ColorRect
@export var animator_viewblocker : AnimationPlayer
@export var animator_streetlights : AnimationPlayer
@export var music_ending : AudioStreamPlayer2D
@export var dia : DialogueEnding
@export var label_congrats : Label
@export var label_array : Array[Label]
@export var uiparent : Control
@export var animator_congrats : AnimationPlayer
@export var animator_cash : AnimationPlayer
@export var fireArray : Array[TextFire]
@export var speaker_load : AudioStreamPlayer2D
@export var speaker_ambience : AudioStreamPlayer2D
@export var cntrl_ambience : SpeakerController
@export var cntrl_endingmusic : SpeakerController
@export var animator_anykey : AnimationPlayer
@export var animator_pan : AnimationPlayer
var waitingForInput = false

func _input(event):
	if event is InputEventKey and event.pressed:
		if (waitingForInput): 
			ExitGame()
			waitingForInput = false

func BeginEnding():
	cam.moving = false
	animator_pan.play("pan to brief")
	music_ending.play()
	AmbienceFade()
	await get_tree().create_timer(10.67, false).timeout
	viewblocker.visible = true
	animator_viewblocker.play("snap")
	animator_pan.stop()
	SetupEnding()
	FinalScore()
	for l in label_array: l.visible = false
	label_congrats.visible = false
	await get_tree().create_timer(1.2, false).timeout
	animator_viewblocker.play("fade out")
	await get_tree().create_timer(6, false).timeout
	#SHOW UI
	label_congrats.visible = true
	animator_congrats.play("wobble it")
	animator_cash.play("wobble it")
	dia.ShowText_Forever(glob_text_congratulations)
	await get_tree().create_timer(2, false).timeout
	for i in fireArray:
		speaker_load.pitch_scale = randf_range(.95, 1)
		speaker_load.play()
		await get_tree().create_timer(.15, false).timeout
	await get_tree().create_timer(.5, false).timeout
	for i in range(fireArray.size()):
		if (i == 5): 
			await get_tree().create_timer(.4, false).timeout
			fireArray[i].changed = true
			fireArray[i].speaker.pitch_scale = .15
		fireArray[i].Fire()
		await get_tree().create_timer(.33, false).timeout
	await get_tree().create_timer(3, false).timeout
	GetInput()

func GetInput():
	animator_anykey.play("flicker")
	await get_tree().create_timer(.8, false).timeout
	waitingForInput = true

func ExitGame():
	animator_viewblocker.play("fade in")
	cntrl_endingmusic.FadeOut()
	cntrl_ambience.fadeDuration = 3
	cntrl_ambience.FadeOut()
	isActive = false
	await get_tree().create_timer(4, false).timeout
	get_tree().quit()

var isActive = true
func AmbienceFade():
	await get_tree().create_timer(55, false).timeout
	if (isActive):
		cntrl_ambience.SnapVolume(false)
		speaker_ambience.play()
		cntrl_ambience.FadeIn()

func SetupEnding():
	await get_tree().create_timer(.1, false).timeout
	uiparent.visible = true
	for b in blockout: b.visible = true
	pp.environment.adjustment_brightness = 5.68
	pp.environment.adjustment_contrast = 1.3
	pp.environment.adjustment_saturation = .26
	cam.moving = false
	cam.cam.fov = 60
	animator_streetlights.play("looping")
	animator_backdrop.play("loop exterior")
	animator_cam.play("camera loop car")

var endless_overwriting = false
var endless_roundsbeat = 0
var endless_score = 0
var glob_text_congratulations
func FinalScore():
	var playername = roundManager.playerData.playername
	var shots_fired = roundManager.playerData.stat_shotsFired
	var shells_ejected = roundManager.playerData.stat_shellsEjected
	var doors_kicked = roundManager.playerData.stat_doorsKicked
	var cigarettes_smoked = roundManager.playerData.stat_cigSmoked
	var ml_of_beer_drank = roundManager.playerData.stat_beerDrank
	var max_cash = 70000
	
	var cancer_bills = cigarettes_smoked * 220
	var new_leg_bones_price = doors_kicked * 1000
	var DUI_fine = ml_of_beer_drank * 1.5
	var total_cash = max_cash - cancer_bills - DUI_fine
	if (doors_kicked > 2): total_cash -= new_leg_bones_price
	if (total_cash < 0): total_cash = 0
	
	if (endless_overwriting): total_cash = endless_score
	#if (playername == "sex"): total_cash = 69
	#if (playername == "leet"): total_cash = 1337
	#if (playername == "snoop" or playername == "weed" or playername == "kush"): total_cash = 420
	
	var text_congratulations = "CONGRATULATIONS, " + playername + "!"
	var text_shotsFired = "shots fired ........ " + str(shots_fired)
	if (endless_overwriting): text_shotsFired = "rounds beat ........ " + str(endless_roundsbeat)
	var text_shellsEjected = "shells ejected ..... " + str(shells_ejected)
	var text_doorsKicked = "doors kicked ....... " + str(doors_kicked)
	var text_cigSmoked = "cigarettes smoked .. " + str(cigarettes_smoked)
	var text_beerDrank = "ml of beer drank ... " + str(ml_of_beer_drank)
	var text_totalcash = "total cash: " + str(total_cash) + " $"
	
	glob_text_congratulations = text_congratulations
	
	label_array[0].text = text_shotsFired
	label_array[1].text = text_shellsEjected
	label_array[2].text = text_doorsKicked
	label_array[3].text = text_cigSmoked
	label_array[4].text = text_beerDrank
	label_array[5].text = text_totalcash
