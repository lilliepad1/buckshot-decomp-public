class_name Endless extends Node

@export var roundManager : RoundManager
@export var smokerdude : Node3D
@export var display : StandardMaterial3D
@export var displayrounds : CompressedTexture2D

func SetupEndless():
	smokerdude.visible = false
	roundManager.endless = true
	roundManager.playerData.hasReadIntroduction = true
	roundManager.playerData.hasReadItemSwapIntroduction = true
	roundManager.playerData.hasReadItemDistributionIntro = true
	roundManager.playerData.hasReadItemDistributionIntro2 = true
	roundManager.playerData.numberOfDialogueRead = 3
	roundManager.playerData.skippingShellDescription = true
	roundManager.playerData.indicatorShown = true
	roundManager.playerData.cutterDialogueRead = true
	roundManager.playerData.seenGod = true
	roundManager.shellSpawner.skipDialoguePresented = true
	roundManager.shellLoadingSpedUp = true
	display.albedo_texture = displayrounds
