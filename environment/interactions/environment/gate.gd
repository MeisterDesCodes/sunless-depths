extends Node2D


@export var lifetime: int

@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var interaction = get_node("Interaction")
@onready var animationPlayer = get_node("AnimationPlayer")


var isOpen: bool = false


func _ready():
	interaction.onInteract.connect(interact)


func interact(body):
	if isOpen:
		closeGate()
	else:
		openGate()


func openGate():
	isOpen = true
	animationPlayer.play("Gate Open")
	playerScene.soundComponent.onGateInteraction()


func closeGate():
	isOpen = false
	animationPlayer.play("Gate Close")
	playerScene.soundComponent.onGateInteraction()
