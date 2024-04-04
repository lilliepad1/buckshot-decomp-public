class_name CameraShaker extends Node

@export var camera_to_shake : Camera3D

@export var intensity : float
@export var duration : float
var shake_timer = 0.0
var initial_h_offset = 0.0
var initial_v_offset = 0.0

func _ready():
	if camera_to_shake:
		initial_h_offset = camera_to_shake.h_offset
		initial_v_offset = camera_to_shake.v_offset

func Shake():
	if camera_to_shake:
		shake_timer = duration

func _process(delta):
	if shake_timer > 0:
		if camera_to_shake:
			var h_offset = randf() * intensity - intensity / 2.0
			var v_offset = randf() * intensity - intensity / 2.0
			camera_to_shake.h_offset = initial_h_offset + h_offset
			camera_to_shake.v_offset = initial_v_offset + v_offset
			shake_timer -= delta
	else:
		if camera_to_shake:
			camera_to_shake.h_offset = initial_h_offset
			camera_to_shake.v_offset = initial_v_offset
