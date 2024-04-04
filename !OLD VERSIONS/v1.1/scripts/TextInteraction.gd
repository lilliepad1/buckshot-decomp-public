class_name TextInteraction extends Node

@export var text : Label3D
@export var interaction : InteractionManager
@export var dur : float
@export var colorvalue_min : float
@export var colorvalue_max : float

var elapsed = 0
var moving = false
var fs1 = true
var fs2 = false
var colorvalue_current = 0.0
var colorvalue_next = 0.0

func _process(delta):
	CheckStatus()
	LerpOpacity()

func CheckStatus():
	if (interaction.activeParent == text):
		if (!fs1):
			BeginLerp()
			fs2 = false
			fs1 = true
	else:
		if (!fs2):
			EndLerp()
			fs1 = false
			fs2 = true

func BeginLerp():
	colorvalue_current = text.modulate.r
	colorvalue_next = colorvalue_max
	elapsed = 0
	moving = true
	pass

func EndLerp():
	colorvalue_current = text.modulate.r
	colorvalue_next = colorvalue_min
	elapsed = 0
	moving = true
	pass

func LerpOpacity():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / dur, 0.0, 1.0)
		var color = lerp(colorvalue_current, colorvalue_next, c)
		text.modulate = Color(color, color, color, text.modulate.a)
	pass
