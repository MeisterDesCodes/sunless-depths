extends Node2D


@export var lifetime: int

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


func closeGate():
	isOpen = false
	animationPlayer.play("Gate Close")
