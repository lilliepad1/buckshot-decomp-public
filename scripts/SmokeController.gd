class_name SmokeController extends Node

@export var particle_barrel : GPUParticles3D
@export var particle_chamber : GPUParticles3D

func _ready():
	SpawnSmoke("barrel")
	SpawnSmoke("chamber")

func SpawnSmoke(alias : String):
	match (alias):
		"barrel":
			particle_barrel.restart()
		"chamber":
			particle_chamber.restart()
