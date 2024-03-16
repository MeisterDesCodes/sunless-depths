extends Node2D


@onready var interaction = $"Interaction"

var lifetime: int = 3

func _ready():
	interaction.entered.connect(enter)


func enter(body):
	if lifetime > 0:
		interaction.dropResources([preload("res://items/resources/rubble.tres"),
			preload("res://items/resources/planks.tres")], 1, 3, 250, body)
		lifetime -= 1
		if lifetime == 0:
			queue_free()
