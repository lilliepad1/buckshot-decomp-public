class_name InteractionBranch extends Node

@export var interactionAlias : String
@export var itemName : String
@export var interactionAllowed : bool
@export var isGrid : bool
@export var gridIndex : int
@export var itemGridIndex : int
@export var interactionInvalid : bool
@export var signatureButton_letterAlias : String
@export var signatureButton_specialAlias : String
@export var assignedSignatureButton : SignButton

func _ready():
	if (signatureButton_letterAlias != ""):
		assignedSignatureButton = get_parent().get_child(3)
	if (signatureButton_specialAlias != ""):
		assignedSignatureButton = get_parent().get_child(3)
