extends Node2D


@export var lifetime: int

@onready var interaction = get_node("Interaction")


func _ready():
	interaction.onEnter.connect(enter)


func enter(body):
	interaction.completed = true
	interaction.approachLabel.visible = false
	body.global_position = Vector2(490, 355)
	get_tree().get_root().get_node("Game")._ready()
