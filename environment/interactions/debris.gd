extends Node2D


@export var dropResources: Array[DropResource]
@export var lifetime: int

@onready var interaction = get_node("Interaction")


func _ready():
	interaction.onInteract.connect(interact)


func interact(body):
	interaction.dropResources(dropResources, 250, body)
