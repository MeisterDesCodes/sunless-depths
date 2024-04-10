extends Node2D


@export var dropResources: Array[DropResource]

@onready var interaction = $"Interaction"

var lifetime: int = 3

func _ready():
	interaction.onEnter.connect(enter)


func enter(body):
	if lifetime > 0:
		interaction.dropResources(dropResources, 250, body)
		lifetime -= 1
		if lifetime == 0:
			interaction.completed = true
			interaction.approachLabel.visible = false
