extends Node2D


@export var lifetime: int

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var interactionComponent = get_node("InteractionConponent")

var menuScene


func _ready():
	interactionComponent.onInteract.connect(interact)


func interact(body):
	if playerScene.atLocation:
		playerScene.atLocation = false
		playerScene.atExit = true
		menuScene = UILoaderS.loadUIScene(preload("res://UI/menu/menu-ui.tscn"))
		menuScene._on_map_pressed()
		playerScene.currentExit = self
	else:
		playerScene.atLocation = true
		LocationLoaderS.loadArea(LocationLoaderS.nextLocation)

