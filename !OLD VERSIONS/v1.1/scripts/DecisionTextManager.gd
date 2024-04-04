class_name DecisionTextManager extends Node

@export var textArray : Array[TextInteraction]
@export var colliderArray : Array[StaticBody3D]
@export var animator : AnimationPlayer

func _ready():
	for i in range(colliderArray.size()):
		colliderArray[i].collision_layer = 0
		colliderArray[i].collision_mask = 0

func SetUI(state : bool):
	if (state):
		for i in range(colliderArray.size()):
			colliderArray[i].collision_layer = 1
			colliderArray[i].collision_mask = 1
		animator.play("show text")
	else:
		for i in range(colliderArray.size()):
			colliderArray[i].collision_layer = 0
			colliderArray[i].collision_mask = 0
		animator.play("hide text")
