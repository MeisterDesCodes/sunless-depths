extends Node2D


@export var dropResources: Array[DropResource]
@export var lifetime: int
@export var interactionCost: float

@onready var interaction = get_node("Interaction")


func _ready():
	interaction.onInteract.connect(interact)


func interact(body):
	interaction.playerScene.updateHud.emit(interactionCost * 0.1, interactionCost * 0.25, interactionCost)
	interaction.dropResources(dropResources, UtilsS.resourceDropSpeed, body)
