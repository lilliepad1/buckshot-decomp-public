class_name SegmentManager extends Node

@export var speaker : AudioStreamPlayer2D
@export var roundManager : RoundManager
@export var camera : CameraManager
@export var mat : StandardMaterial3D
var dur = 2
var elapsed = 0
var moving = false

func _process(delta):
	LerpSegment()

func GrowBarrel():
	var prevsocket = camera.activeSocket
	roundManager.currentShotgunDamage = 1
	roundManager.barrelSawedOff = false
	camera.BeginLerp("grow barrel")
	await get_tree().create_timer(.6, false).timeout
	ShowSegment()
	speaker.play()
	await get_tree().create_timer(1.8, false).timeout
	camera.BeginLerp(prevsocket)
	await get_tree().create_timer(.6, false).timeout
	pass

func HideSegment():
	moving = false
	mat.albedo_color = Color(1, 1, 1, 0)

func ShowSegment():
	elapsed = 0
	moving = true

func LerpSegment():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / dur, 0.0, 1.0)
		var alpha = lerp(0, 1, c)
		mat.albedo_color = Color(1, 1, 1, alpha)
