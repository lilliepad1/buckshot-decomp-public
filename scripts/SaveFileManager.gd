class_name SaveFileManager extends Node

const savePath := "user://buckshotroulette.save"
var data = {}
@export var roundManager : RoundManager
@export var isMainMenu : bool

func _ready():
	if (!isMainMenu): LoadGame()
	pass

func SaveGame():
	data = {
		"has_read_introduction": roundManager.playerData.hasReadIntroduction,
		"has_read_item_swap_introduction": roundManager.playerData.hasReadItemSwapIntroduction,
		"has_read_item_distribution_intro": roundManager.playerData.hasReadItemDistributionIntro,
		"current_batch_index": roundManager.playerData.currentBatchIndex,
		"player_entering_from_death": roundManager.playerData.playerEnteringFromDeath,
		"test_value": roundManager.playerData.testValue,
		"has_read_item_distribution_intro_2": roundManager.playerData.hasReadItemDistributionIntro2,
		"number_of_dialogue_read": roundManager.playerData.numberOfDialogueRead,
		"skipping_shell_description": roundManager.playerData.skippingShellDescription,
		"indicator_shown": roundManager.playerData.indicatorShown,
		"cutter_dialogue_read": roundManager.playerData.cutterDialogueRead,
		"entering_from_true_death": roundManager.playerData.enteringFromTrueDeath,
		"has_signed_waiver": roundManager.playerData.hasSignedWaiver,
		"seen_hint": roundManager.playerData.seenHint,
		"seen_god": roundManager.playerData.seenGod,
		"player_name": roundManager.playerData.playername,
		
		"stat_shotsFired": roundManager.playerData.stat_shotsFired,
		"stat_shellsEjected": roundManager.playerData.stat_shellsEjected,
		"stat_doorsKicked": roundManager.playerData.stat_doorsKicked,
		"stat_cigSmoked": roundManager.playerData.stat_cigSmoked,
		"stat_beerDrank": roundManager.playerData.stat_beerDrank
	}
	var file = FileAccess.open(savePath, FileAccess.WRITE)
	file.store_var(data)
	#file.store_var(roundManager.playerData.hasReadIntroduction)
	#file.store_var(roundManager.playerData.hasReadItemSwapIntroduction)
	#file.store_var(roundManager.playerData.hasReadItemDistributionIntro)
	#file.store_var(roundManager.playerData.currentBatchIndex)
	#file.store_var(roundManager.playerData.playerEnteringFromDeath)
	#file.store_var(roundManager.playerData.testValue)
	#file.store_var(roundManager.playerData.hasReadItemDistributionIntro2)
	#file.store_var(roundManager.playerData.numberOfDialogueRead)
	#file.store_var(roundManager.playerData.skippingShellDescription)
	#file.store_var(roundManager.playerData.indicatorShown)
	#file.store_var(roundManager.playerData.cutterDialogueRead)
	#file.store_var(roundManager.playerData.enteringFromTrueDeath)
	#file.store_var(roundManager.playerData.hasSignedWaiver)
	#file.store_string(roundManager.playerData.playername)
	file.close()

func LoadGame():
	if (FileAccess.file_exists(savePath)):
		var file = FileAccess.open(savePath, FileAccess.READ)
		data = file.get_var()
		roundManager.playerData.hasReadIntroduction = data.has_read_introduction
		roundManager.playerData.hasReadItemSwapIntroduction = data.has_read_item_swap_introduction
		roundManager.playerData.hasReadItemDistributionIntro = data.has_read_item_distribution_intro
		roundManager.playerData.currentBatchIndex = data.current_batch_index
		roundManager.playerData.playerEnteringFromDeath = data.player_entering_from_death
		roundManager.playerData.testValue = data.test_value
		roundManager.playerData.hasReadItemDistributionIntro2 = data.has_read_item_distribution_intro_2
		roundManager.playerData.numberOfDialogueRead = data.number_of_dialogue_read
		roundManager.playerData.skippingShellDescription = data.skipping_shell_description
		roundManager.playerData.indicatorShown = data.indicator_shown
		roundManager.playerData.cutterDialogueRead = data.cutter_dialogue_read
		roundManager.playerData.enteringFromTrueDeath = data.entering_from_true_death
		roundManager.playerData.hasSignedWaiver = data.has_signed_waiver
		roundManager.playerData.playername = data.player_name
		roundManager.playerData.seenHint = data.seen_hint
		roundManager.playerData.seenGod = data.seen_god
		
		roundManager.playerData.stat_shotsFired = data.stat_shotsFired
		roundManager.playerData.stat_shellsEjected = data.stat_shellsEjected
		roundManager.playerData.stat_doorsKicked = data.stat_doorsKicked
		roundManager.playerData.stat_cigSmoked = data.stat_cigSmoked
		roundManager.playerData.stat_beerDrank = data.stat_beerDrank
		#roundManager.playerData.hasReadIntroduction = file.get_var(roundManager.playerData.hasReadIntroduction)
		#roundManager.playerData.hasReadItemSwapIntroduction = file.get_var(roundManager.playerData.hasReadItemSwapIntroduction)
		#roundManager.playerData.hasReadItemDistributionIntro = file.get_var(roundManager.playerData.hasReadItemDistributionIntro)
		#roundManager.playerData.currentBatchIndex = file.get_var(roundManager.playerData.currentBatchIndex)
		#roundManager.playerData.playerEnteringFromDeath = file.get_var(roundManager.playerData.playerEnteringFromDeath)
		#roundManager.playerData.testValue = file.get_var(roundManager.playerData.testValue)
		#roundManager.playerData.hasReadItemDistributionIntro2 = file.get_var(roundManager.playerData.testValue)
		#roundManager.playerData.numberOfDialogueRead = file.get_var(roundManager.playerData.numberOfDialogueRead)
		#roundManager.playerData.skippingShellDescription = file.get_var(roundManager.playerData.skippingShellDescription)
		#roundManager.playerData.indicatorShown = file.get_var(roundManager.playerData.indicatorShown)
		#roundManager.playerData.cutterDialogueRead = file.get_var(roundManager.playerData.cutterDialogueRead)
		#roundManager.playerData.enteringFromTrueDeath = file.get_var(roundManager.playerData.enteringFromTrueDeath)
		#roundManager.playerData.hasSignedWaiver = file.get_var(roundManager.playerData.hasSignedWaiver)
		#roundManager.playerData.playername = file.get_as_text(roundManager.playerData.playername)
		file.close()

func ClearSave():
	if (FileAccess.file_exists(savePath)): DirAccess.remove_absolute(savePath)
