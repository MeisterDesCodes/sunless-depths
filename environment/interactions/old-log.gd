extends Node2D


@export var dropResources: Array[DropResource]
@export var lifetime: int

@onready var interaction = get_node("Interaction")


func _ready():
	interaction.onEnter.connect(enter)


func enter(body):
	interaction.dropResources(dropResources, 250, body)
