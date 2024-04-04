class_name FilterController extends Node

@export var panDuration : float
@export var lowPassDefaultValue : float
@export var lowPassMaxValue : float

var effect_lowPass
var moving = false
var elapsed = 0
var begin
var dest

func _ready():
	effect_lowPass = AudioServer.get_bus_effect(1, 0)
	effect_lowPass.cutoff_hz = lowPassDefaultValue

func _process(delta):
	PanLowPass_HighLow()

func BeginSnap(valueTo : float):
	moving = false
	elapsed = 0
	effect_lowPass.cutoff_hz = valueTo

func BeginPan(valueFrom : float, valueTo : float):
	moving = false
	elapsed = 0
	begin = valueFrom
	dest = valueTo
	moving = true

func PanLowPass_HighLow():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / panDuration, 0.0, 1.0)
		c = ease(c, 0.4)
		var panValue = lerpf(begin, dest, c)
		effect_lowPass.cutoff_hz = panValue
