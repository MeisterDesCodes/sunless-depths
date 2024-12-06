extends Node2D


@export var lifetime: int

@onready var playerScene = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var interaction = get_node("Interaction")


func _ready():
	interaction.onInteract.connect(interact)


func interact(body):
	playerScene.hudUI.restockOxygen()
