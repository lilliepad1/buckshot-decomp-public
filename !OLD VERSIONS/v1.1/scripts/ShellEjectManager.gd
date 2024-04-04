class_name ShellEjectManager extends Node

@export var mesh : MeshInstance3D
@export var shellSpawner : ShellSpawner
@export var mat_blank : StandardMaterial3D
@export var mat_live : StandardMaterial3D
@export var mat_brass : StandardMaterial3D
@export var animator : AnimationPlayer
@export var animator_fader : AnimationPlayer
@export var isDealerSide : bool
@export var smoke : SmokeController

var hasFaded = false

func _ready():
	mesh.set_surface_override_material(0, mat_brass)

func EjectShell():
	shellSpawner.roundManager.playerData.stat_shellsEjected += 1
	animator_fader.play("RESET")
	if (shellSpawner.sequenceArray[0] == "live"): mesh.set_surface_override_material(1, mat_live)
	else: mesh.set_surface_override_material(1, mat_blank)
	mesh.visible = true
	if(!isDealerSide): animator.play("ejecting shell_player1")
	else: animator.play("eject shell")
	if (shellSpawner.sequenceArray[0] == "live"):
		smoke.SpawnSmoke("chamber")
	shellSpawner.sequenceArray.remove_at(0)
	hasFaded = false
	pass

func BeerEjection_player():
	shellSpawner.roundManager.playerData.stat_shellsEjected += 1
	animator_fader.play("RESET")
	if (shellSpawner.sequenceArray[0] == "live"): mesh.set_surface_override_material(1, mat_live)
	else: mesh.set_surface_override_material(1, mat_blank)
	mesh.visible = true
	animator.play("ejecting shell_player1")
	shellSpawner.sequenceArray.remove_at(0)
	hasFaded = false
	pass

func BeerEjection_dealer():
	shellSpawner.roundManager.playerData.stat_shellsEjected += 1
	animator_fader.play("RESET")
	if (shellSpawner.sequenceArray[0] == "live"): mesh.set_surface_override_material(1, mat_live)
	else: mesh.set_surface_override_material(1, mat_blank)
	mesh.visible = true
	animator.play("eject shell beer")
	shellSpawner.sequenceArray.remove_at(0)
	hasFaded = false
	pass

func DeathEjection():
	animator_fader.play("RESET")
	if (shellSpawner.sequenceArray[0] == "live"): mesh.set_surface_override_material(1, mat_live)
	else: mesh.set_surface_override_material(1, mat_blank)
	mesh.visible = true
	if(!isDealerSide): animator.play("ejecting shell_player1")
	else: animator.play("eject shell")
	if (shellSpawner.sequenceArray[0] == "live"):
		smoke.SpawnSmoke("chamber")
	shellSpawner.sequenceArray.remove_at(0)
	hasFaded = false
	pass

func FadeOutShell():
	if(!hasFaded):
		animator_fader.play("fade out shell")
		hasFaded = true
