extends Node2D


@export var dropResources: Array[DropResource]
@export var lifetime: int

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var interaction = get_node("Interaction")
@onready var animationPlayer = get_node("AnimationPlayer")


func _ready():
	interaction.onInteract.connect(interact)


func interact(body):
	animationPlayer.play("Open Sarcophagus")
	playerScene.soundComponent.onSarcophagusInteraction()
	await get_tree().create_timer(3).timeout
	interaction.dropResources(dropResources, UtilsS.resourceDropSpeed, body)
