extends Node2D


@export var lifetime: int

@onready var interaction = get_node("Interaction")


func _ready():
	interaction.onInteract.connect(interact)


func interact(body):
	LocationLoaderS.exploredLocations.append(LocationLoaderS.currentLocation.location)
