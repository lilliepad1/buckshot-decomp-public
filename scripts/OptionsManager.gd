class_name OptionsManager extends Node

@export var ui_windowed : CanvasItem
@export var ui_fullscreen : CanvasItem
@export var button_windowed : ButtonClass
@export var button_fullscreen : ButtonClass
@export var menu : MenuManager
@export var ui_volume : Label
const savePath := "user://buckshotroulette_options.save"
var data = {}
var setting_volume = 1
var setting_windowed = false

func _ready():
	LoadSettings()

func Adjust(alias : String):
	match(alias):
		"increase":
			if setting_volume != 1:
				setting_volume = setting_volume + 0.05
				if setting_volume > 1:
					setting_volume = 1
			UpdateDisplay()
			ApplySettings_volume()
		"decrease":
			if setting_volume != 0:
				setting_volume = setting_volume - 0.05
			if setting_volume < 0:
				setting_volume = 0
			UpdateDisplay()
			ApplySettings_volume()
		"windowed":
			setting_windowed = true
			ApplySettings_window()
		"fullscreen":
			setting_windowed = false
			ApplySettings_window()
	if (alias != "increase" && alias != "decrease"): menu.ResetButtons()
	
func ApplySettings_volume():
	AudioServer.set_bus_volume_db(0, linear_to_db(setting_volume))
	UpdateDisplay()
	pass

func UpdateDisplay():
	ui_volume.text = str(snapped(setting_volume * 100, .01)) + "%"


func ApplySettings_window():
	if (!setting_windowed): 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		ui_fullscreen.modulate.a = 1
		ui_windowed.modulate.a = .5
		button_fullscreen.mainActive = false
		button_windowed.mainActive = true
	else: 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		ui_fullscreen.modulate.a = .5
		ui_windowed.modulate.a = 1
		button_fullscreen.mainActive = true
		button_windowed.mainActive = false
	pass

func SaveSettings():
	data = {
		#"has_read_introduction": roundManager.playerData.hasReadIntroduction,
		"setting_volume": setting_volume,
		"setting_windowed": setting_windowed
	}
	var file = FileAccess.open(savePath, FileAccess.WRITE)
	file.store_var(data)
	file.close()

func LoadSettings():
	if (FileAccess.file_exists(savePath)):
		var file = FileAccess.open(savePath, FileAccess.READ)
		data = file.get_var()
		setting_volume = data.setting_volume
		setting_windowed = data.setting_windowed
		file.close()
		ApplySettings_volume()
		ApplySettings_window()
