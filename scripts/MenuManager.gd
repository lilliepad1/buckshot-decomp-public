class_name MenuManager extends Node

@export var savefile : SaveFileManager
@export var cursor : CursorManager
@export var animator_intro : AnimationPlayer
@export var speaker_music : AudioStreamPlayer2D
@export var speaker_start : AudioStreamPlayer2D
@export var buttons : Array[ButtonClass]
@export var buttons_options : Array[ButtonClass]
@export var screen_main : Array[Control]
@export var screen_creds : Array[Control]
@export var screen_options : Array[Control]
@export var title : Node3D
@export var waterfalls : Array[AnimationPlayer]
@export var optionmanager : OptionsManager

func _ready():
	Show("main")
	buttons[0].connect("is_pressed", Start)
	buttons[1].connect("is_pressed", Credits)
	buttons[2].connect("is_pressed", Exit)
	buttons[3].connect("is_pressed", Return)
	buttons[4].connect("is_pressed", Options)
	buttons[5].connect("is_pressed", Return)
	buttons_options[0].connect("is_pressed", IncreaseVol)
	buttons_options[1].connect("is_pressed", DecreaseVol)
	buttons_options[2].connect("is_pressed", SetFull)
	buttons_options[3].connect("is_pressed", SetWindowed)
	Intro()

func Intro():
	cursor.SetCursor(false, false)
	await get_tree().create_timer(.5, false).timeout
	speaker_music.play()
	animator_intro.play("splash screen")
	await get_tree().create_timer(9, false).timeout
	cursor.SetCursor(true, false)
	for i in buttons_options: 
		i.isActive = false
		i.SetFilter("ignore")
	buttons[0].isActive = true
	buttons[0].SetFilter("stop")
	buttons[1].isActive = true
	buttons[1].SetFilter("stop")
	buttons[2].isActive = true
	buttons[2].SetFilter("stop")
	buttons[4].isActive = true
	buttons[4].SetFilter("stop")
	pass

func Buttons(state : bool):
	if (!state):
		for i in buttons:
			i.isActive = false
			i.SetFilter("ignore")
	else: 
		for i in buttons:
			i.isActive = true
			i.SetFilter("stop")

func Show(what : String):
	title.visible = false
	for i in screen_main: i.visible = false
	for i in screen_creds: i.visible = false
	for i in screen_options: i.visible = false
	if (what == "credits"): for i in screen_creds: i.visible = true
	else: if (what == "main"): 
		for i in screen_main: i.visible = true 
		title.visible = true
	else: if (what == "options"):
		for i in screen_options: i.visible = true
	else:
		pass

func ResetButtons():
	for b in buttons:
		b.ui.modulate.a = 1
	cursor.SetCursorImage("point")

func Start():
	Buttons(false)
	ResetButtons()
	Show("e")
	speaker_music.stop()
	animator_intro.play("snap")
	for w in waterfalls: w.pause()
	speaker_start.play()
	cursor.SetCursor(false, false)
	savefile.ClearSave()
	await get_tree().create_timer(4, false).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func Credits():
	ResetButtons()
	Show("credits")
	Buttons(false)
	buttons[3].isActive = true
	buttons[3].SetFilter("stop")
	ResetButtons()

func Exit():
	Buttons(false)
	ResetButtons()
	speaker_music.stop()
	animator_intro.play("snap2")
	cursor.SetCursor(false, false)
	await get_tree().create_timer(.5, false).timeout
	get_tree().quit()

func Return():
	Show("main")
	Buttons(false)
	buttons[0].isActive = true
	buttons[0].SetFilter("stop")
	buttons[1].isActive = true
	buttons[1].SetFilter("stop")
	buttons[2].isActive = true
	buttons[2].SetFilter("stop")
	buttons[4].isActive = true
	buttons[4].SetFilter("stop")
	for i in buttons_options: i.isActive = false
	for i in buttons_options: i.SetFilter("ignore")
	optionmanager.SaveSettings()
	ResetButtons()

func Options():
	Show("options")
	Buttons(false)
	buttons[5].isActive = true
	buttons[5].SetFilter("stop")
	for i in buttons_options: 
		i.isActive = true
		i.SetFilter("stop")
	ResetButtons()

func IncreaseVol():
	optionmanager.Adjust("increase")
func DecreaseVol():
	optionmanager.Adjust("decrease")
func SetWindowed():
	optionmanager.Adjust("windowed")
func SetFull():
	optionmanager.Adjust("fullscreen")
