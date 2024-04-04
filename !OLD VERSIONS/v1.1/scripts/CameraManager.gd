class_name CameraManager extends Node

@export var cam : Camera3D
@export var obj : Node3D

@export var defib : DefibCutter
@export var animator_background : AnimationPlayer
@export var speaker_pan : AudioStreamPlayer2D
@export var socketArray: Array[CameraSocket]

@export var dur : float
@export var isPlayingSound : bool
var moving = false
var elapsed = 0
var currentPos : Vector3
var currentRot : Vector3
var currentFov : float
var activeIndex
var activeSocket : String
var pos_previous : Vector3
var rot_previous : Vector3
@export var anim_test : AnimationPlayer

func _ready():
	pass


func _process(delta):
	LerpMovement()
	pass

func CutOutBackground():
	animator_background.play("cut out")
func FadeInBackground():
	animator_background.play("fade in")

func BeginLerp(lerpName : String):
	#SavePrevious()
	#speaker_pan.play()
	PanSound()
	activeSocket = lerpName
	for i in range(socketArray.size()):
		if (lerpName == socketArray[i].socketName):
			activeIndex = i
			currentPos = cam.transform.origin
			currentRot = cam.rotation_degrees
			currentFov = cam.fov
			elapsed = 0
			moving = true
	pass

func BeginLerpCutSegment():
	PanSound()
	activeSocket = "dealer cut shotgun"
	for i in range(socketArray.size()):
		if (activeSocket == socketArray[i].socketName):
			activeIndex = i
			currentPos = cam.transform.origin
			currentRot = cam.rotation_degrees
			currentFov = cam.fov
			elapsed = 0
			moving = true

func BeginLerpEnemy():
	PanSound()
	activeSocket = "enemy"
	for i in range(socketArray.size()):
		if (activeSocket == socketArray[i].socketName):
			activeIndex = i
			currentPos = cam.transform.origin
			currentRot = cam.rotation_degrees
			currentFov = cam.fov
			elapsed = 0
			moving = true

func PanSound():
	var pitch = randf_range(.5, 1)
	speaker_pan.pitch_scale = pitch
	if (isPlayingSound): speaker_pan.play()

func SavePrevious():
	rot_previous = cam.rotation_degrees
	pos_previous = cam.transform.origin

func LerpMovement():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / dur, 0.0, 1.0)
		c = ease(c, 0.2)
		var pos = lerp(currentPos, socketArray[activeIndex].pos, c)
		var rot = lerp(currentRot, socketArray[activeIndex].rot, c)
		var fov = lerp(currentFov, socketArray[activeIndex].fov, c)
		cam.fov = fov
		cam.transform.origin = pos
		cam.rotation_degrees = rot
		pass
