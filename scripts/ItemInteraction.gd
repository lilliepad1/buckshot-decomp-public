class_name ItemInteraction extends Node

@export var roundManager : RoundManager
@export var dealerIntelligence : DealerIntelligence
@export var cursor : CursorManager
@export var perm : PermissionManager
@export var itemManager : ItemManager
@export var lerpDuration : float
@export var pos_hand : Vector3
@export var rot_hand : Vector3
@export var animator_dealerHands : AnimationPlayer
@export var animator_playerHands : AnimationPlayer
@export var camera : CameraManager
@export var shellEject_player : ShellEjectManager
@export var speaker_pickup : AudioStreamPlayer2D
@export var speaker_breakcuffs : AudioStreamPlayer2D

var temp_itemParent
var pos_current
var pos_next
var rot_current
var rot_next
var temp_interaction
var temp_indicator
var elapsed = 0
var moving = false

func _process(delta):
	LerpMovement()

func PickupItemFromTable(itemParent : Node3D, passedItemName : String):
	#SET INTERACTION PERMISSIONS, HIDE CURSOR
	perm.SetIndicators(false)
	perm.SetInteractionPermissions(false)
	perm.RevertDescriptionUI()
	cursor.SetCursor(false, false)
	#GET VARIABLES
	temp_itemParent = itemParent
	temp_indicator = itemParent.get_child(0)
	temp_interaction = itemParent.get_child(1)
	#PLAY PICKUP SOUND
	speaker_pickup.stream = temp_indicator.sound_pickup
	speaker_pickup.pitch_scale = randf_range(.93, 1.0)
	speaker_pickup.play()
	#INTERACTION PERMISSIONS
	#perm.SetIndicators(false)
	#cursor.SetCursor(false, false)
	#perm.SetInteractionPermissions(false)
	temp_indicator.lerpEnabled = false
	temp_indicator.interactionAllowed = false
	temp_indicator.SnapToMax()
	temp_interaction.interactionAllowed = false
	#LERP
	pos_current = temp_itemParent.transform.origin
	rot_current = temp_itemParent.rotation_degrees
	pos_next = pos_hand
	rot_next = rot_hand
	elapsed = 0
	moving = true
	await get_tree().create_timer(lerpDuration -.1, false).timeout
	moving = false
	RemovePlayerItemFromGrid(temp_itemParent)
	temp_itemParent.queue_free() #check where player grid index is given, and remove item from player item array, unoccupy given grid
	InteractWith(passedItemName)

func InteractWith(itemName : String):
	#INTERACTION
	match (itemName):
		"handcuffs":
			animator_dealerHands.play("dealer get handcuffed")
			await get_tree().create_timer(1, false).timeout
			camera.BeginLerp("enemy")
			await get_tree().create_timer(1.3, false).timeout
			camera.BeginLerp("dealer handcuffs")
			roundManager.dealerCuffed = true
			dealerIntelligence.dealerAboutToBreakFree = false
			await get_tree().create_timer(1.3, false).timeout
			camera.BeginLerp("home")
			await get_tree().create_timer(.6, false).timeout
			EnablePermissions()
		"beer":
			roundManager.playerData.stat_beerDrank += 330
			var isFinalShell = false
			if (roundManager.shellSpawner.sequenceArray.size() == 1): isFinalShell = true
			animator_playerHands.play("player use beer")
			await get_tree().create_timer(1.4, false).timeout
			shellEject_player.FadeOutShell()
			await get_tree().create_timer(4.2, false).timeout
			#check if ejected last shell
			if (!isFinalShell): EnablePermissions()
			else:
				roundManager.StartRound(true)
		"magnifying glass":
			animator_playerHands.play("player use magnifier")
			var length = animator_playerHands.get_animation("player use magnifier").get_length()
			await get_tree().create_timer(length + .2, false).timeout
			EnablePermissions()
		"cigarettes":
			roundManager.playerData.stat_cigSmoked += 1
			animator_playerHands.play("player use cigarettes")
			await get_tree().create_timer(5, false).timeout
			itemManager.numberOfCigs_player -= 1
			EnablePermissions()
		"handsaw":
			animator_playerHands.play("player use handsaw")
			roundManager.barrelSawedOff = true
			roundManager.currentShotgunDamage = 2
			await get_tree().create_timer(4.28 + .2, false).timeout
			EnablePermissions()

func EnablePermissions():
	perm.SetStackInvalidIndicators()
	perm.SetIndicators(true)
	perm.SetInteractionPermissions(true)
	perm.RevertDescriptionUI()
	cursor.SetCursor(true, true)

func PlaySound_BreakHandcuffs():
	speaker_breakcuffs.play()

func RemovePlayerItemFromGrid(parent : Node3D):
	var indic = parent.get_child(0)
	var inter = parent.get_child(1)
	itemManager.items_dynamicIndicatorArray.erase(indic)
	itemManager.items_dynamicInteractionArray.erase(inter)
	itemManager.gridOccupiedArray[inter.itemGridIndex] = false
	itemManager.numberOfOccupiedGrids -= 1

func LerpMovement():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / lerpDuration, 0.0, 1.0)
		#c = ease(c, 0.1)
		temp_itemParent.transform.origin = lerp(pos_current, pos_next, c)
		temp_itemParent.rotation_degrees = lerp(rot_current, rot_next, c)
