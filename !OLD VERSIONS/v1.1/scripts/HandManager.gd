class_name HandManager extends Node

@export var dealerAI : DealerIntelligence
@export var itemManager : ItemManager
@export var animator_hands : AnimationPlayer
@export var animator_dealerHeadLook : AnimationPlayer
@export var handArray_L : Array[Node3D]
@export var handArray_R : Array[Node3D]
@export var gridOffsetArray : Array[Vector3] #ITEM'S ACTIVE GRID INDEX STORED IN PICKUP INDICATOR: dealerGridIndex

@export var handParent_L : Node3D
@export var handParent_R : Node3D
@export var hand_defaultL : Node3D
@export var hand_defaultR : Node3D
@export var hand_cigarettepack : Node3D 	#L
@export var hand_beer : Node3D 				#L
@export var hand_handcuffs : Node3D 		#R
@export var hand_handsaw : Node3D 			#R
@export var hand_magnifier : Node3D 		#R

@export var lerpDuration : float
@export var handRot_left : Vector3 #hand rotation when grabing from left grids
@export var handRot_right : Vector3 #same shit
@export var parentOriginal_posL : Vector3
@export var parentOriginal_rotL : Vector3
@export var parentOriginal_posR : Vector3
@export var parentOriginal_rotR : Vector3
var moving = false
var lerping_L = false
var lerping_R = false
var pos_current
var pos_next
var rot_current
var rot_next
var elapsed = 0
var orig_pos
var orig_rot
var activeHandParent
var activeItemToGrab

func _process(delta):
	LerpHandMovement()

func PickupItemFromTable(itemName : String):
	dealerAI.Speaker_HandCrack()
	var activeIndex
	var activeInstance
	var whichHandToGrabWith
	var whichGridSide
	var matchIndex
	activeItemToGrab = itemName 
	for i in range(itemManager.itemArray_instances_dealer.size()):
		if (itemName == itemManager.itemArray_instances_dealer[i].get_child(1).itemName):
			activeInstance = itemManager.itemArray_instances_dealer[i]
			matchIndex = i
			break
	activeIndex = activeInstance.get_child(0).dealerGridIndex
	ToggleHandVisible("BOTH", false)
	hand_defaultL.visible = true
	hand_defaultR.visible = true
	if (itemName == "beer" or itemName == "cigarettes"): whichHandToGrabWith = "left"
	else: whichHandToGrabWith = "right"
	whichGridSide = activeInstance.get_child(0).whichSide
	animator_hands.play("RESET")
	BeginHandLerp(whichHandToGrabWith, activeIndex, whichGridSide)
	if (whichGridSide == "right"): animator_dealerHeadLook.play("dealer look right")
	else: animator_dealerHeadLook.play("dealer look left")
	await get_tree().create_timer(lerpDuration -.4, false).timeout
	if (whichHandToGrabWith == "right"): hand_defaultR.visible = false
	else: hand_defaultL.visible = false
	dealerAI.Speaker_HandCrack()
	match (itemName):
		"handsaw":
			hand_handsaw.visible = true
		"magnifying glass":
			hand_magnifier.visible = true
		"handcuffs":
			hand_handcuffs.visible = true
		"cigarettes":
			hand_cigarettepack.visible = true
			itemManager.numberOfCigs_dealer -= 1
		"beer":
			hand_beer.visible = true
	itemManager.itemArray_instances_dealer.remove_at(matchIndex)
	var tempindicator = activeInstance.get_child(0)
	var gridname = tempindicator.dealerGridName
	itemManager.gridParentArray_enemy_available.append(gridname)
	activeInstance.queue_free()
	await get_tree().create_timer(.2, false).timeout
	ReturnHand()
	if (whichGridSide == "right"): animator_dealerHeadLook.play("dealer look forward from right")
	else: animator_dealerHeadLook.play("dealer look forward from left")
	await get_tree().create_timer(lerpDuration + .01, false).timeout
	HandFailsafe()
	var animationName = "dealer use " + itemName
	animator_hands.play("RESET")
	animator_hands.play(animationName)
	var length = animator_hands.get_animation(animationName).get_length()
	moving = false
	await get_tree().create_timer(length, false).timeout
	pass

func ToggleHandVisible(selectedHand : String, state : bool):
	if (selectedHand == "L" or "BOTH"):
		for i in range(handArray_L.size()):
			if (state): handArray_L[i].visible = true
			else: handArray_L[i].visible = false
	if (selectedHand == "R" or "BOTH"):
		for i in range(handArray_R.size()):
			if (state): handArray_R[i].visible = true
			else: handArray_R[i].visible = false

func BeginHandLerp(whichHand : String, gridIndex : int, whichSide : String):
	if (whichHand == "right"): activeHandParent = handParent_R
	else: activeHandParent = handParent_L
	pos_current = activeHandParent.transform.origin
	rot_current = activeHandParent.rotation_degrees
	orig_pos = pos_current
	orig_rot = rot_current
	pos_next = gridOffsetArray[gridIndex]
	lerping_L = false
	lerping_R = false
	if(whichSide == "right"): rot_next = handRot_right
	else: rot_next = handRot_left
	if(whichHand == "right"): lerping_R = true
	else: lerping_L = true
	elapsed = 0
	moving = true

func ReturnHand():
	pos_current = activeHandParent.transform.origin
	rot_current = activeHandParent.rotation_degrees
	pos_next = orig_pos
	rot_next = orig_rot
	elapsed = 0
	moving = true

func HandFailsafe():
	handParent_L.transform.origin = parentOriginal_posL
	handParent_L.rotation_degrees = parentOriginal_rotL
	handParent_R.transform.origin = parentOriginal_posR
	handParent_R.rotation_degrees = parentOriginal_rotR

func LerpHandMovement():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / lerpDuration, 0.0, 1.0)
		c = ease(c, 0.2)
		if (lerping_L):
			var pos = lerp(pos_current, pos_next, c)
			var rot = lerp(rot_current, rot_next, c)
			handParent_L.transform.origin = pos
			handParent_L.rotation_degrees = rot
		if (lerping_R):
			var pos = lerp(pos_current, pos_next, c)
			var rot = lerp(rot_current, rot_next, c)
			handParent_R.transform.origin = pos
			handParent_R.rotation_degrees = rot
		pass
























