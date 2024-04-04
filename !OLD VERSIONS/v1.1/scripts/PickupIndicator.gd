class_name PickupIndicator extends Node

@export var description : DescriptionManager
@export var interaction : InteractionManager
@export var obj : Node3D
@export var collider : Node3D

@export var dur : float
@export var axisOffset : float
@export var originalAxis : float
@export var activeAxis : String

@export var uiArray : Array[Label]
@export var itemName : String
@export_multiline var itemDescription : String
@export var whichSide : String
@export var dealerGridIndex : int
@export var sound_placeDown : AudioStream
@export var sound_indicatorPickup : AudioStream
@export var sound_indicatorPutdown : AudioStream
@export var sound_pickup : AudioStream
var speaker_indicatorCheck : AudioStreamPlayer2D
var locationInDynamicArray
var itemManager

var isDealerItem = false
var dealerGridName
var lerpEnabled = true
var interactionAllowed = false
var interactionInvalid = false
var current = 0
var next = 0
var elapsed = 0
var moving = false
var fs = false
var fs2 = false

func _ready():
	speaker_indicatorCheck = get_node("/root/main/speaker parent/speaker_indicator check")
	interaction = get_node("/root/main/standalone managers/interaction manager")
	description = get_node("/root/main/standalone managers/description manager")
	itemManager = get_node("/root/main/standalone managers/item manager")

func _process(delta):
	if (lerpEnabled): LerpMovement()
	CheckIfActive()
	pass

func CheckIfActive():
	if (interactionAllowed && !interactionInvalid):
		if (interaction.activeParent != null and interaction.activeParent == collider):
			if (!fs):
				BeginPickup()
				fs2 = false
				fs = true
		if (interaction.activeParent != collider):
			if (!fs2):
				Revert()
				fs = false
				fs2 = true
	pass

func BeginPickup():
	speaker_indicatorCheck.pitch_scale = randf_range(.9, 1.0)
	speaker_indicatorCheck.play()
	current = originalAxis
	next = axisOffset	
	description.uiArray[0].text = itemName
	description.uiArray[1].text = itemName
	description.uiArray[2].text = itemDescription
	description.uiArray[3].text = itemDescription
	elapsed = 0
	moving = true
	description.BeginLerp()
	itemManager.hasBegun = true
	pass

func Revert():
	#if (itemManager.hasBegun): description.EndLerp()
	itemManager.hasBegun = false
	match(activeAxis):
		"x":
			current = obj.transform.origin.x
		"y":
			current = obj.transform.origin.y
		"z":
			current = obj.transform.origin.z
	next = originalAxis
	elapsed = 0
	moving = true
	pass

func LerpMovement():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / dur, 0.0,  1.0)
		var pos = lerp(current, next, c)
		match(activeAxis):
			"x":
				obj.transform.origin = Vector3(pos, obj.transform.origin.y, obj.transform.origin.z)
			"y":
				obj.transform.origin = Vector3(obj.transform.origin.x, pos, obj.transform.origin.z)
			"z":
				obj.transform.origin = Vector3(obj.transform.origin.x, obj.transform.origin.y, pos)

func SnapToMax():
	match(activeAxis):
		"x":
			obj.transform.origin = Vector3(axisOffset, obj.transform.origin.y, obj.transform.origin.z)
		"y":
			obj.transform.origin = Vector3(obj.transform.origin.x, axisOffset, obj.transform.origin.z)
		"z":
			obj.transform.origin = Vector3(obj.transform.origin.x, obj.transform.origin.y, axisOffset)

func SnapToMin():
	match(activeAxis):
		"x":
			obj.transform.origin = Vector3(originalAxis, obj.transform.origin.y, obj.transform.origin.z)
		"y":
			obj.transform.origin = Vector3(obj.transform.origin.x, originalAxis, obj.transform.origin.z)
		"z":
			obj.transform.origin = Vector3(obj.transform.origin.x, obj.transform.origin.y, originalAxis)











