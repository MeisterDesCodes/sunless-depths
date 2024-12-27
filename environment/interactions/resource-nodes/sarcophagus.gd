extends Node2D


@export var dropResources: Array[DropResource]
@export var lifetime: int
@export var interactionCost: float

@onready var playerScene: CharacterBody2D = get_tree().get_root().get_node("GameController/Game/Entities/Player")
@onready var interaction = get_node("Interaction")
@onready var animationPlayer = get_node("AnimationPlayer")


func _ready():
	interaction.onInteract.connect(interact)


func interact(body):
	interaction.playerScene.updateHud.emit(interactionCost * 0.1, interactionCost * 0.25, interactionCost)
	animationPlayer.play("Open Sarcophagus")
	playerScene.soundComponent.onSarcophagusInteraction()
	await UtilsS.createTimer(3)
	interaction.dropResources(dropResources, UtilsS.resourceDropSpeed, body)
