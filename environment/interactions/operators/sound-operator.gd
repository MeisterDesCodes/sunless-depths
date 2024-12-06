extends Node2D


@export var sound: AudioStreamMP3
@export var lifetime: int

@onready var game = get_tree().get_root().get_node("GameController/Game")
@onready var interaction = get_node("Interaction")


func _ready():
	interaction.onInteract.connect(interact)


func interact(body):
	game.soundComponent.playDiscovery()
