extends Node2D


@export var lifetime: int

@onready var playerScene = get_tree().get_root().get_node("Game/Entities/Player")
@onready var interactionComponent = get_node("InteractionConponent")


func _ready():
	interactionComponent.onEnter.connect(enter)


func enter(body):
	if playerScene.atLocation:
		playerScene.atLocation = false
		playerScene.atExit = true
		var scene = UILoaderS.loadUIScene(preload("res://UI/menu/menu-ui.tscn"))
		scene._on_map_pressed()
	else:
		playerScene.atLocation = true
		#Load new Location

