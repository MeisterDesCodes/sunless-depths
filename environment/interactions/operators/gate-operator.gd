extends Node2D


@export var lifetime: int
@export var gate: Node2D

@onready var interaction = get_node("Interaction")


func _ready():
	interaction.onInteract.connect(interact)


func interact(body):
	gate.interact(body)
