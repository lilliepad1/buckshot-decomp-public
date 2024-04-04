class_name SpeakerController extends Node

@export var fadeDuration : float
@export var fadeDuration_pitch : float
@export var lowestPitchValue : float
var speaker : AudioStreamPlayer2D
var elapsed = 0
var elapsed_pitch = 0
var moving = false
var moving_pitch = false
var originalVolumeDB : float
var originalPitch : float
var currentPitch : float
var nextPitch : float
var currentVolume : float
var nextVolume : float

func _ready():
	speaker = self.get_parent()
	originalVolumeDB = speaker.volume_db
	originalPitch = speaker.pitch_scale

func _process(delta):
	LerpVolume()
	LerpPitch()

func SnapVolume(state : bool):
	moving = false
	if (state): speaker.volume_db = originalVolumeDB
	else: speaker.volume_db = linear_to_db(0)

func BeginPitchShift(pitchFrom : float, pitchTo : float):
	moving_pitch = false
	elapsed_pitch = 0
	currentPitch = pitchFrom
	nextPitch = pitchTo
	moving_pitch = true

func FadeIn():
	elapsed = 0
	currentVolume = db_to_linear(speaker.volume_db)
	nextVolume = db_to_linear(originalVolumeDB)
	moving = true

func FadeOut():
	elapsed = 0	
	currentVolume = db_to_linear(speaker.volume_db)
	nextVolume = 0
	moving = true

func LerpVolume():
	if (moving):
		elapsed += get_process_delta_time()
		var c = clampf(elapsed / fadeDuration, 0.0, 1.0)
		var vol = lerpf(currentVolume, nextVolume, c)
		speaker.volume_db = linear_to_db(vol)

func LerpPitch():
	if (moving_pitch):
		elapsed_pitch += get_process_delta_time()
		var c = clampf(elapsed_pitch / fadeDuration_pitch, 0.0, 1.0)
		c = ease(c, 0.4)
		var pitch = lerpf(currentPitch, nextPitch, c)
		speaker.pitch_scale = pitch

















