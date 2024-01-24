class_name ItemManager extends Node

@export var grid : GridIndicator
@export var cursor : CursorManager
@export var roundManager : RoundManager
@export var dialogue : Dialogue
@export var camera : CameraManager
@export var comp : CompartmentManager
@export var interaction_intake : InteractionBranch
@export var instanceArray : Array[ItemResource]
@export var instanceArray_dealer : Array[ItemResource]
@export var availableItemArray : Array[String]
@export var itemSpawnParent : Node3D
@export var lerpDuration : float
@export var gridParentArray : Array[Node3D]
@export var gridParentArray_enemy : Array[Node3D]
var gridParentArray_enemy_available : Array[Node3D]
@export var gridOccupiedArray : Array[bool]
@export var stringNumberArray : Array[String]
@export var gridParent_1 : Node3D
@export var gridParent_2 : Node3D
@export var gridParent_3 : Node3D
@export var gridParent_4 : Node3D
@export var soundArray_itemGrab : Array[AudioStream]
@export var speaker_itemgrab : AudioStreamPlayer2D
@export var speaker_placedown : AudioStreamPlayer2D
@export var anim_spook : AnimationPlayer
@export var speakercontroller_musicmain : SpeakerController
@export var speaker_god : AudioStreamPlayer2D
var itemGrabSoundIndex = 0
var itemArray_dealer : Array[String]
var itemArray_instances_dealer : Array[Node3D]
var itemArray_player : Array[String]
var hasBegun = false
var items_dynamicIndicatorArray : Array[PickupIndicator]
var items_dynamicInteractionArray : Array[InteractionBranch]

var numberOfCigs_player = 0
var numberOfCigs_dealer = 0
var playerItemStringArray
var availableItemsToGrabArray_player
var availableItemsToGrabArray_dealer
var numberOfItemsGrabbed_enemy = 0
var numberOfItemsGrabbed = 0
var numberOfOccupiedGrids = 0
var activeItem_offset_pos
var activeItem_offset_rot
var activeItem
var activeItem_enemy
var elapsed = 0
var moving = false
var pos_current
var pos_next
var rot_current
var rot_next
var temp_indicator
var temp_interaction

func _ready():
	playerItemStringArray = []
	availableItemsToGrabArray_player = availableItemArray
	availableItemsToGrabArray_dealer = availableItemArray
	ResetDealerGrid()

func _process(delta):
	LerpItem()

func ItemClear_Remote():
	var itemParentChildrenArray = itemSpawnParent.get_children()
	for i in range(itemParentChildrenArray.size()):
		if (itemParentChildrenArray[i].get_child(0) is PickupIndicator):
			requestingItemClear = true
			break
	if (requestingItemClear):
		camera.BeginLerp("home")
		await get_tree().create_timer(.8, false).timeout
		SetupItemClear()
		comp.animator_compartment.play("clear items")
		await get_tree().create_timer(1.6).timeout
		comp.animator_compartment.play("hide items")
		await get_tree().create_timer(.8, false).timeout
	else:
		camera.BeginLerp("home")
		await get_tree().create_timer(.8, false).timeout
		comp.animator_compartment.play("hide items")
		await get_tree().create_timer(.8, false).timeout

var newBatchHasBegun = false
var requestingItemClear = false
func BeginItemGrabbing():
	roundManager.ignoring = false
	numberOfItemsGrabbed = 0
	if (roundManager.playerData.hasReadItemSwapIntroduction): camera.BeginLerp("home")
	else: camera.BeginLerp("enemy")
	var itemParentChildrenArray = itemSpawnParent.get_children()
	#CLEAR ITEMS FROM TABLE
	if (newBatchHasBegun):
		for i in range(itemParentChildrenArray.size()):
			if (itemParentChildrenArray[i].get_child(0) is PickupIndicator):
				requestingItemClear = true
				break
		if (requestingItemClear):
			await get_tree().create_timer(.8, false).timeout
			SetupItemClear()
			comp.animator_compartment.play("clear items")
			await get_tree().create_timer(1.4).timeout
		newBatchHasBegun = false
	
	await get_tree().create_timer(.8, false).timeout
	if (!roundManager.playerData.hasReadItemSwapIntroduction):
		dialogue.ShowText_ForDuration("LET'S MAKE THIS A LITTLE\nMORE INTERESTING ...", 3)
		await get_tree().create_timer(3, false).timeout
		camera.BeginLerp("home")
		await get_tree().create_timer(.8, false).timeout
		roundManager.playerData.hasReadItemSwapIntroduction = true
	comp.CycleCompartment("show briefcase")
	await get_tree().create_timer(.8, false).timeout
	if (comp.isHiding_items): comp.CycleCompartment("show items")
	await get_tree().create_timer(.8, false).timeout
	camera.BeginLerp("briefcase")
	await get_tree().create_timer(.8, false).timeout
	
	if (!roundManager.playerData.hasReadItemDistributionIntro):
		var stringIndex = roundManager.roundArray[roundManager.currentRound].numberOfItemsToGrab
		var string = stringNumberArray[stringIndex]
		dialogue.ShowText_Forever(string+" ITEMS EACH.")
		await get_tree().create_timer(2.5, false).timeout
		dialogue.ShowText_Forever("MORE ITEMS BEFORE\nEVERY LOAD.")
		await get_tree().create_timer(2.5, false).timeout
		dialogue.HideText()
		roundManager.playerData.hasReadItemDistributionIntro = true

	if (!roundManager.playerData.hasReadItemDistributionIntro2 && roundManager.roundArray[roundManager.currentRound].hasIntro2):
		var stringIndex = roundManager.roundArray[roundManager.currentRound].numberOfItemsToGrab
		var string = stringNumberArray[stringIndex]
		dialogue.ShowText_Forever(string+" ITEMS EACH.")
		await get_tree().create_timer(2.5, false).timeout
		dialogue.HideText()
		roundManager.playerData.hasReadItemDistributionIntro2 = true
	#ALLOW ITEM GRAB
	cursor.SetCursor(true, true)
	interaction_intake.interactionAllowed = true
	pass

func EndItemGrabbing():
	GrabItems_Enemy()
	GridParents(false)
	interaction_intake.interactionAllowed = false
	cursor.SetCursor(false, false)
	await get_tree().create_timer(.45, false).timeout
	comp.CycleCompartment("hide briefcase")
	await get_tree().create_timer(1, false).timeout
	camera.BeginLerp("home")
	await get_tree().create_timer(.9, false).timeout
	moving = false
	roundManager.ReturnFromItemGrabbing()
	pass

func GrabSpook():
	interaction_intake.interactionAllowed = false
	cursor.SetCursor(false, false)
	PlayItemGrabSound()
	speakercontroller_musicmain.SnapVolume(false)
	speaker_god.play()
	anim_spook.play("grab form")
	await get_tree().create_timer(2 + .8, false).timeout
	anim_spook.play("put back")
	PlayItemGrabSound()
	camera.BeginLerp("briefcase")
	speaker_god.stop()
	speakercontroller_musicmain.FadeIn()
	await get_tree().create_timer(.8, false).timeout
	cursor.SetCursor(true, true)
	interaction_intake.interactionAllowed = true

var randindex = -1
var spook_counter = 0
var spook_fired = false
func GrabItem():
	if (roundManager.playerData.currentBatchIndex == 1 && roundManager.currentRound == 1):
		if (spook_counter == 1 && !spook_fired && !roundManager.playerData.seenGod):
			GrabSpook()
			roundManager.playerData.seenGod = true
			spook_fired = true
			return
		spook_counter += 1
	#GET RANDOM ITEM
	PlayItemGrabSound()
	interaction_intake.interactionAllowed = false
	var selectedResource : ItemResource
	if (numberOfCigs_player >= 2):
		availableItemsToGrabArray_player.erase("cigarettes")
	else:
		var hasInArray = false
		for i in range(availableItemsToGrabArray_player.size()):
			if (availableItemsToGrabArray_dealer[i] == "cigarettes"):
				hasInArray = true
				break
		if (!hasInArray): availableItemsToGrabArray_player.append("cigarettes")
	randindex = randi_range(0, availableItemsToGrabArray_player.size() - 1)
	numberOfItemsGrabbed += 1
	#SPAWN ITEM
	for i in range(instanceArray.size()):
		if (availableItemsToGrabArray_player[randindex] == instanceArray[i].itemName):
			selectedResource = instanceArray[i]
	var itemInstance = selectedResource.instance.instantiate()
	activeItem = itemInstance
	itemSpawnParent.add_child(itemInstance)
	itemInstance.transform.origin = selectedResource.pos_inBriefcase
	itemInstance.rotation_degrees = selectedResource.rot_inBriefcase
	activeItem_offset_pos = selectedResource.pos_offset
	activeItem_offset_rot = selectedResource.rot_offset
	#ADD ITEM TO PICKUP INDICATOR & INTERACTION BRANCH ARRAY
	if (numberOfOccupiedGrids != 8):
		temp_indicator = activeItem.get_child(0)
		temp_interaction = activeItem.get_child(1)
		items_dynamicIndicatorArray.append(temp_indicator)
		items_dynamicInteractionArray.append(temp_interaction)
		var ind = items_dynamicIndicatorArray.size() - 1
		temp_indicator.locationInDynamicArray = ind
	#DISABLE ITEM COLLIDER
	var childArray = activeItem.get_children()
	for i in childArray.size():
		if (childArray[i] is StaticBody3D): childArray[i].get_child(0).disabled = true
	#LERP TO HAND
	pos_current = itemInstance.transform.origin
	rot_current = itemInstance.rotation_degrees
	pos_next = selectedResource.pos_inHand
	rot_next = selectedResource.rot_inHand
	elapsed = 0
	moving = true
	await get_tree().create_timer(lerpDuration - .2, false).timeout
	if (!roundManager.playerData.indicatorShown): grid.ShowGridIndicator()
	if (numberOfOccupiedGrids != 8):
		GridParents(true)
	else:
		#NOT ENOUGH SPACE. PUT ITEM BACK AND END ITEM GRABBING
		dialogue.ShowText_Forever("OUT OF SPACE.")
		await get_tree().create_timer(1.8, false).timeout
		dialogue.ShowText_Forever("HOW UNFORTUNATE ...")
		await get_tree().create_timer(2.2, false).timeout
		dialogue.HideText()
		pos_current = activeItem.transform.origin
		rot_current = activeItem.rotation_degrees
		pos_next = selectedResource.pos_inBriefcase
		rot_next = selectedResource.rot_inBriefcase
		elapsed = 0
		moving = true
		cursor.SetCursor(false, false)
		PlayItemGrabSound()
		await get_tree().create_timer(lerpDuration, false).timeout
		moving = false
		activeItem.queue_free()
		EndItemGrabbing()
	pass

func PlaceDownItem(gridIndex : int):
	numberOfOccupiedGrids += 1
	gridOccupiedArray[gridIndex] = true
	moving = false
	#activeItem.get_parent().remove_child(activeItem)
	#gridParentArray[gridIndex].add_child(activeItem)
	var temp_indicator = activeItem.get_child(0)
	if (temp_interaction.itemName == "cigarettes"): numberOfCigs_player += 1
	pos_current = activeItem.transform.origin
	rot_current = activeItem.rotation_degrees
	pos_next = gridParentArray[gridIndex].transform.origin + activeItem_offset_pos
	rot_next = gridParentArray[gridIndex].rotation_degrees + activeItem_offset_rot
	elapsed = 0
	moving = true
	temp_interaction.itemGridIndex = gridIndex
	if (temp_indicator.sound_placeDown != null):
		speaker_placedown.stream = temp_indicator.sound_placeDown
		speaker_placedown.play()
	var childArray = activeItem.get_children()
	for i in childArray.size():
		if (childArray[i] is StaticBody3D): childArray[i].get_child(0).disabled = false
	if (numberOfItemsGrabbed == roundManager.roundArray[roundManager.currentRound].numberOfItemsToGrab):
		#END ITEM GRABBING
		EndItemGrabbing()
	else:
		#GRAB NEXT ITEM
		GridParents(false)
		await get_tree().create_timer(lerpDuration, false).timeout
		interaction_intake.interactionAllowed = true
	pass

var firstItem = true
func GrabItems_Enemy():
	var selectedResource
	for i in range(roundManager.roundArray[roundManager.currentRound].numberOfItemsToGrab):
		if (numberOfItemsGrabbed_enemy != 8):
			if (numberOfCigs_dealer >= 2):
				availableItemsToGrabArray_dealer.erase("cigarettes")
			else:
				var hasInArray = false
				for k in range(availableItemsToGrabArray_dealer.size()):
					if (availableItemsToGrabArray_dealer[k] == "cigarettes"):
						hasInArray = true
						break
				if (!hasInArray): availableItemsToGrabArray_dealer.append("cigarettes")
			
			var randindex = randi_range(0, availableItemsToGrabArray_dealer.size() - 1)
			#SPAWN ITEM
			for c in range(instanceArray_dealer.size()):
				if (availableItemArray[randindex] == instanceArray_dealer[c].itemName):
					selectedResource = instanceArray_dealer[c]
					#ADD STRING TO DEALER ITEM ARRAY
					itemArray_dealer.append(instanceArray_dealer[c].itemName)
			var itemInstance = selectedResource.instance.instantiate()
			var temp_itemIndicator = itemInstance.get_child(0)
			temp_itemIndicator.isDealerItem = true
			#ADD INSTANCE TO DEALER ITEM ARRAY (mida vittu this code is getting out of hand)
			itemArray_instances_dealer.append(itemInstance)
			activeItem_enemy = itemInstance
			itemSpawnParent.add_child(activeItem_enemy)
			#PLACE ITEM ON RANDOM GRID
			var randgrid = randi_range(0, gridParentArray_enemy_available.size() - 1)
			#higher than z0 is right
			var gridname = gridParentArray_enemy_available[randgrid]
			activeItem_enemy.transform.origin = gridParentArray_enemy_available[randgrid].transform.origin + selectedResource.pos_offset
			activeItem_enemy.rotation_degrees = gridParentArray_enemy_available[randgrid].rotation_degrees + selectedResource.rot_offset
			if (activeItem_enemy.transform.origin.z > 0): temp_itemIndicator.whichSide = "right"
			else: temp_itemIndicator.whichSide = "left"
			temp_itemIndicator.dealerGridIndex = gridParentArray_enemy_available[randgrid].get_child(0).activeIndex
			temp_itemIndicator.dealerGridName = gridname
			if (activeItem_enemy.get_child(1).itemName == "cigarettes"): numberOfCigs_dealer += 1
			gridParentArray_enemy_available.erase(gridname)
			numberOfItemsGrabbed_enemy += 1
		pass
	pass

func UseItem_Dealer(itemName : String):
	match (itemName):
		"beer":
			pass
	pass

func ResetDealerGrid():
	#CLEAR DEALER GRID
	numberOfItemsGrabbed_enemy = 0
	gridParentArray_enemy_available = []
	for i in range(gridParentArray_enemy.size()):
		gridParentArray_enemy_available.append(gridParentArray_enemy[i])

func SetupItemClear():
	instancesToDelete = []
	#DEALER
	numberOfCigs_dealer = 0
	numberOfItemsGrabbed_enemy = 0
	gridParentArray_enemy_available = []
	for i in range(gridParentArray_enemy.size()):
		gridParentArray_enemy_available.append(gridParentArray_enemy[i])
	itemArray_dealer = []
	
	#PLAYER
	numberOfCigs_player = 0
	items_dynamicIndicatorArray = []
	items_dynamicInteractionArray = []
	for i in range(gridOccupiedArray.size()):
		gridOccupiedArray[i] = false
	numberOfOccupiedGrids = 0
	
	var childarray = itemSpawnParent.get_children()
	for i in range(childarray.size()):
		if (childarray[i].get_child(0) is PickupIndicator):
			instancesToDelete.append(childarray[i])
	
	var spawnChildren = itemSpawnParent.get_children()
	#PARENT INSTANCES TO APPROPRIATE GRID COMPARTMENT PARENT
	for i in range(spawnChildren.size()):
		if (spawnChildren[i].get_child(0) is PickupIndicator):
			var objPos_x = spawnChildren[i].transform.origin.x
			var objPos_z = spawnChildren[i].transform.origin.z
			if (objPos_x < 0 && objPos_z > 0): 
				var orig = spawnChildren[i].global_transform
				spawnChildren[i].get_parent().remove_child(spawnChildren[i])
				gridParent_1.add_child(spawnChildren[i])
				spawnChildren[i].global_transform = orig
			if (objPos_x < 0 && objPos_z < 0): 
				var orig = spawnChildren[i].global_transform
				spawnChildren[i].get_parent().remove_child(spawnChildren[i])
				gridParent_2.add_child(spawnChildren[i])
				spawnChildren[i].global_transform = orig
			if (objPos_x > 0 && objPos_z > 0): 
				var orig = spawnChildren[i].global_transform
				spawnChildren[i].get_parent().remove_child(spawnChildren[i])
				gridParent_3.add_child(spawnChildren[i])
				spawnChildren[i].global_transform = orig
			if (objPos_x > 0 && objPos_z < 0): 
				var orig = spawnChildren[i].global_transform
				spawnChildren[i].get_parent().remove_child(spawnChildren[i])
				gridParent_4.add_child(spawnChildren[i])
				spawnChildren[i].global_transform = orig

var instancesToDelete = []
func ClearAllItems():
	#DELETE INSTANCES
	for i in range (instancesToDelete.size()):
		instancesToDelete[i].queue_free()
	itemArray_instances_dealer = []

func GridParents(setState : bool):
	if (setState):
		for i in range(gridParentArray.size()):
			gridParentArray[i].get_child(1).get_child(0).disabled = false
			if(gridOccupiedArray[i] == false): gridParentArray[i].get_child(0).interactionAllowed = true
	else:
		for i in range(gridParentArray.size()):
			gridParentArray[i].get_child(1).get_child(0).disabled = true
			gridParentArray[i].get_child(0).interactionAllowed = false

func PlayItemGrabSound():
	speaker_itemgrab.stream = soundArray_itemGrab[itemGrabSoundIndex]
	speaker_itemgrab.play()
	if (itemGrabSoundIndex != soundArray_itemGrab.size() - 1): itemGrabSoundIndex += 1
	else: itemGrabSoundIndex = 0
	pass

func LerpItem():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / lerpDuration, 0.0, 1.0)
		c = ease(c, 0.4)
		var pos = lerp(pos_current, pos_next, c)
		var rot = lerp(rot_current, rot_next, c)
		activeItem.transform.origin = pos
		activeItem.rotation_degrees = rot















