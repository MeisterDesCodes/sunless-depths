extends Node2D


@export var dropResources: Array[DropResource]

@onready var interaction = $"Interaction"

var lifetime: int = 1

func _ready():
	interaction.onEnter.connect(enter)


func enter(body):
	if lifetime > 0:
		interaction.dropResources(dropResources, 150, body)
		lifetime -= 1
		if lifetime == 0:
			pass