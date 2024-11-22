extends Node2D


@export var lifetime: int

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var interactionComponent = get_node("InteractionConponent")
@onready var exitParticles = get_node("ExitParticles")

var direction: Enums.exitDirection


func _ready():
	interactionComponent.onInteract.connect(interact)


func update():
	if !isActive():
		interactionComponent.queue_free()
		exitParticles.queue_free()


func isActive():
	return !playerScene.isInCave || direction != LocationLoaderS.currentFromDirection


func interact(body):
	if !isActive():
		return
	
	playerScene.atExit = true
	if !playerScene.isInCave:
		var menuScene = UILoaderS.loadUIScene(preload("res://UI/menu/menu-ui.tscn"))
		menuScene._on_map_pressed()
	else:
		playerScene.isInCave = false
		LocationLoaderS.loadArea(LocationLoaderS.nextLocation)

