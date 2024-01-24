class_name DescriptionManager extends Node

@export var interaction : InteractionManager
@export var uiArray : Array[Label]
@export var dur : float

var elapsed
var moving = false
var current_opacity = 0.0
var next_opacity = 1.0

var started = false

func _ready():
	HideText()

func _process(delta):
	LerpText()
	CheckInteraction()

func HideText():
	for i in range(uiArray.size()):
		uiArray[i].modulate.a = 0
	pass

func CheckInteraction():
	if (interaction.activeParent != null):
		var childArray = interaction.activeParent.get_children()
		var found = false
		for i in range(childArray.size()):
			if (childArray[i] is PickupIndicator):
				found = true
				return
		if (!found && started):
			EndLerp()
			started = false

func BeginLerp():
	started = true
	current_opacity = uiArray[0].modulate.a
	next_opacity = 1.0
	elapsed = 0.0
	moving = true
	pass
	
func EndLerp():
	current_opacity = uiArray[0].modulate.a
	next_opacity = 0.0
	elapsed = 0.0
	moving = true
	pass
	
func LerpText():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / dur, 0.0, 1.0)
		var opacity = lerp(current_opacity, next_opacity, c)
		for i in range(uiArray.size()):
			var color = Color(uiArray[i].modulate.r, uiArray[i].modulate.g, uiArray[i].modulate.b, opacity)
			uiArray[i].modulate = color
	pass
